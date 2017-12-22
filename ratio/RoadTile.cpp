//
//  RoadTile.cpp
//  Bike AI
//
//  Created by Cheolgi Kim on 2017. 1. 1..
//  Copyright © 2017년 Ratio. All rights reserved.
//

#include <iostream>
#include <memory>
#include <map>
#include "tile/tileTask.h"
#include "data/tileData.h"
#include "data/propertyItem.h"
#include "data/formats/mvt.h"
#include "data/networkDataSource.h"
#include "util/mapProjection.h"
#include "log.h"
#include "ratio_coord.h"
#include "RoadTile.h"
#include "platform.h"
#include "ratio_platform.h"

using namespace std;


namespace ratiobike {
    inline void MercPointSetAtTile(MercPoint& p, TileID& tileId, glm::vec3 pt)
    {
        MercPoint p2;
        p.x = (tileId.x << (32 - tileId.z)) + (pt.x * (1 << (32 - tileId.z))) - 1;
        p.y = (tileId.y << (32 - tileId.z)) + (1 - pt.y) * (1 << (32 - tileId.z));

        // 여기
        if((((uint32_t)p.x) >> (32 - tileId.z)) > tileId.x) {
            p.x = ((tileId.x + 1) << (32 - tileId.z));
        }

        if((((uint32_t)p.y) >> (32 - tileId.z)) < tileId.y) {
            p.y = ((tileId.y) << (32 - tileId.z)) - 1;
        }
    }

    void RoadTile::pushRoad(shared_ptr<RoadSegment> road)
    {
        MercPoint p0 = road->points[0];
        MercPoint p1 = road->points[1];

        MercPoint_correctForView(&p0);
        MercPoint_correctForView(&p1);
        
        roads.emplace(p0, road);
        reverseRoads.emplace(p1, road);
    }
    
    class RoadTileManager_impl {
    public:
        void collectTile(const TileID& tileIdToSearch,
                          std::shared_ptr<RoadTileRequester> requester);

        const shared_ptr<RoadTile>& getTileInCache(const TileID& tileId);
        
        std::map<TileID, std::shared_ptr<RoadTile>> activeTiles;

        RoadTileManager_impl(MapSourceType type, std::string urlTemplate);
        
    private:
        void processRequest(const shared_ptr<RoadTile> & tile);

        std::map<TileID, std::shared_ptr<TileTask>> tileTasks;
        std::shared_ptr<TileSource> mapSource;
        MapSourceType type;
        
        // tile cache 관련 자료구조
        void pushTileInCache(shared_ptr<RoadTile> tile);
        
        std::map<TileID, std::shared_ptr<RoadTile>> tileCacheMap;
        std::shared_ptr<RoadTile> tileCacheBegin;
        std::shared_ptr<RoadTile> tileCacheEnd;
        size_t tileCacheSize;
        
        // tile requester 관련 자료구조
        std::multimap<TileID, std::shared_ptr<RoadTileRequester>> requesters;
        
        std::string urlTemplate;
        
        std::unique_ptr<MapProjection> mapProjection;
        
    };

    
    RoadTileManager_impl::RoadTileManager_impl(MapSourceType type, std::string urlTemplate)
        : tileCacheSize(0)
    {
        this->type = type;
        
        this->urlTemplate = urlTemplate;

        this->mapProjection = std::make_unique<MercatorProjection>();

        auto networkSource = std::make_unique<NetworkDataSource>(get_platform(), urlTemplate, vector<string>(),
                                                                 false);
 
        switch(this->type) {
            case mapSourceMVT:
                this->mapSource = std::make_shared<TileSource>("rideData", move(networkSource));
                break;
            default:
                this->mapSource = std::make_shared<TileSource>("rideData", move(networkSource));
        }

        tileCacheBegin = tileCacheEnd = make_shared<RoadTile>(TileID(0,0,0));
        
        //return this;
    }

    /*
     * Tile Cache management
     */
    
    const shared_ptr<RoadTile>& RoadTileManager_impl::getTileInCache(const TileID& tileId)
    {
        auto tileFoundIter = this->tileCacheMap.find(tileId);
        
        if(tileFoundIter != this->tileCacheMap.end()) {
            auto tile = tileFoundIter->second;
            
            if(tile != tileCacheBegin) {
                // move tile to front
                auto second = move(tileCacheBegin);
                tileCacheBegin = tile;
                
                // take out tile at the position
                tile->prev->next = move(tile->next);
                tile->prev->next->prev = move(tile->prev);
                
                // push tile at the begining
                tile->next = move(second);
                tile->next->prev = tile;
            }
            
            return tile;
        } else {
            return nullptr;
        }
    }
    
    void RoadTileManager_impl::pushTileInCache(shared_ptr<RoadTile> tile)
    {
        tileCacheMap[tile->tileId] = tile;
        
        auto begin = move(tileCacheBegin);

        tile->next = begin;
        begin->prev = tile;
        tileCacheBegin = move(tile);
        
        if(tileCacheSize >= MAX_TILE_CACHE_QUEUE) {
            auto pop = move(tileCacheEnd->prev);
            pop->prev->next = move(pop->next);
            tileCacheEnd->prev = move(pop->prev);
            
            tileCacheMap.erase(pop->tileId);
        } else {
            tileCacheSize++;
        }
    }
    
    /** @brief 타일이 도착한 후 requester에게 알리기
     */
    void RoadTileManager_impl::processRequest(const shared_ptr<RoadTile>& tile)
    {
        auto tileId = tile->tileId;
        auto requesterRange = requesters.equal_range(tileId);
        list<std::shared_ptr<RoadTileRequester>> reqs;
        
        for(auto it = requesterRange.first; it != requesterRange.second;) {
            // 처리할 requesters들을 확보하여 떼어낸다.
            reqs.push_back(move(it->second));
            it = requesters.erase(it);
        }
        
        for(auto r: reqs) {
            // 떼어낸 requester들에게 처리
            r->onTileArrival(tile);
        }
    }
    
    /** @brief tile들을 수집하여 requester에게 통보하도록 등록하는 함수
     *  @discussion 반드시 main thread에서 불리워 져야 함 (thread safe하지 않음).
     *     requester는 callback을 가지고 있는데 해당 call back 역시 main thread 상에서 불리워짐.
     *     함수안의 tileTask에서 호출하는 call back은 main thread에서 불리워지지 않기 때문에
     *     thread safety를 고려해서 내부 call back 함수를 작성해야 함
     */
    void RoadTileManager_impl::collectTile(const TileID& tileIdToSearch,
                                       shared_ptr<RoadTileRequester> requester )
    {
        LOGD("Collect Tile Start\n");
        // CALLBACK START (콜백은 맨뒤에 수행될 내용이므로 callback 뒷부분부터 읽어야 함.
        auto dataCallback = TileTaskCb{[this](std::shared_ptr<TileTask>&& task) {
            
            std::shared_ptr<TileData> data = Mvt::parseTile(*task, *mapProjection, 0xbeef);
            
            TileID tileId = task->tileId();
            std::shared_ptr<RoadTile> roadTile;
            
            for(auto layer: data->layers) {
                if(layer.name == "roads") {
                    roadTile = std::make_shared<RoadTile>(tileId);
                    for(auto feature: layer.features) {
                        string buf;
                        
                        bool oneWay = feature.props.getAsString("oneway", buf) && buf != "no" && buf != "0";
                        
                        for(auto line: feature.lines) {
                            auto it = line.begin();
                            if(it != line.end()) {
                                MercPoint p1;
                                MercPointSetAtTile(p1, tileId, *it);
                                //printf("ft: (%f, %f):(%x, %x)", it->x, it->y, p1.x, p1.y);
                                for(; it != line.end(); ++it) {
                                    MercPoint p2;
                                    MercPointSetAtTile(p2, tileId, *it);
                                    //printf(" => (%f, %f):(%x, %x)", it->x, it->y, p1.x, p1.y);

                                    if(p1.x != p2.x || p1.y != p2.y) {
                                        shared_ptr<RoadSegment> seg = make_shared<RoadSegment>(p1, p2, oneWay, ROAD_1px);
                                        roadTile->pushRoad(move(seg));
                                        p1 = p2;
                                    }
                                }
                            }
                        }
                        //printf("\n");
                    }
                    break;
                }
            }
            
            delegateToMainThread(std::function<void(void)> {[this, roadTile](void)
            {
                // Tile을 처리한다.
                this->processRequest(roadTile);
                // Tile Cache에 넣는다.
                TileID id = roadTile->tileId;
                this->pushTileInCache(move(roadTile));
                this->tileTasks.erase(id);
            }});
        }};
        // CALLBACK END
        
        auto tile = this->getTileInCache(tileIdToSearch);

        if(tile) {
            requester->onTileArrival(tile);
        } else {
            // 만일 cache에 없다면 requesters에 요청자를 추가한 후 tileTask를 뒤져본다.
            requesters.emplace(tileIdToSearch, requester);
                
            auto itTask = this->tileTasks.find(tileIdToSearch);
                
            //있다면 requester를 추가했으므로 tile이 도착하면 연락이 올 것이다.
            if( this->tileTasks.find(tileIdToSearch) == this->tileTasks.end() ) {
                // 없다면 task를 만들어서 추가한다.
                std::shared_ptr<TileTask> task = this->mapSource->createTask(tileIdToSearch);
                this->tileTasks[tileIdToSearch] = task;
                this->mapSource->loadTileData(std::move(task), dataCallback);
            }
        }
    }

    /*
     *
     * RoadTileManager
     *
     */

    RoadTileManager::RoadTileManager()
    {
        impl = make_unique<RoadTileManager_impl>(MapSourceType::mapSourceMVT,
                                                 "https://tile.mapzen.com/mapzen/vector/v1/all/{z}/{x}/{y}.mvt?api_key=mapzen-ZzW4tEy&");
    }

    /// singleton 객체를 저장하는 장소
    static weak_ptr<RoadTileManager> singletonRoadTileManager;

    /// singleton manager 객체 가져오는 함수
    shared_ptr<RoadTileManager> RoadTileManager::getManager()
    {
        shared_ptr<RoadTileManager> manager = singletonRoadTileManager.lock();
        if(!manager) {
            manager = make_shared<RoadTileManager>();
            singletonRoadTileManager = manager;
        }
        return manager;
    }    

    void RoadTileManager::collectTile(const TileID& tileIdToSearch,
                                      std::shared_ptr<RoadTileRequester> requester)
    {
        impl->collectTile(tileIdToSearch, requester);
    }

    const shared_ptr<RoadTile>& RoadTileManager::getTileInCache(const TileID& tileId)
    {
        return impl->getTileInCache(tileId);
    }
}
