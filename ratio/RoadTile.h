//
//  RoadTile.h
//  Bike AI
//
//  Created by Cheolgi Kim on 2017. 1. 1..
//  Copyright © 2017년 Ratio. All rights reserved.
//

#ifndef RoadTile_h
#define RoadTile_h

#include <string>
#include <vector>
#include <list>
#include <map>
#include <mutex>
#include <cmath>
#include "tileID.h"
#include "ratio_coord.h"

using namespace Tangram;
using namespace std;

    /*
     * MACROs to tronsform between TileID and MercPoint
     */
    
#define TileIdXOfMercPoint(pt,zoom) ((uint32_t)pt.x >> (32 - zoom))
#define TileIdYOfMercPoint(pt,zoom) ((uint32_t)pt.y >> (32 - zoom))
    
#define TileIDOfMercPoint(pt,zoom) TileID(TileIdXOfMercPoint(pt,zoom), TileIdYOfMercPoint(pt,zoom), zoom)

#define MercPointXOfTileId(id,zoom) (id.x << (32 - zoom))
#define MercPointYOfTileId(id,zoom) (id.y << (32 - zoom))
    
#define MercPointOfTileID(id,zoom) MercPoint{.x=MercPointXOfTileId(id,zoom), .y=MercPointYOfTileId(id,zoom)}

namespace ratiobike {

    const size_t MAX_TILE_CACHE_QUEUE = 10;

    typedef enum {
        mapSourceMVT = 0,
        mapSourceTopoJSON,
    } MapSourceType;

    typedef enum {
        RAIL_ROAD,
        ROAD_1px,
        ROAD_2px,
        ROAD_3px
    } road_type_t;

    struct MercPointComparator : public std::binary_function<MercPoint, MercPoint, bool>
    {
        bool operator()(const MercPoint& lhs, const MercPoint& rhs) const
        {
            return ((uint32_t)lhs.x < (uint32_t)rhs.x) || ((lhs.x == rhs.x) && (uint32_t)lhs.y < (uint32_t)rhs.y);
        }
    };
    
    class RoadSegment {
    public:
        inline RoadSegment(MercPoint& p1, MercPoint& p2, bool oneWay, road_type_t roadType)
            : points{p1, p2}, oneWay(oneWay), roadType(roadType) { };
        
        MercPoint points[2];
        bool oneWay;
        road_type_t roadType;

            bool operator==(const RoadSegment& _rhs) const
            {
                return this == &_rhs
                || (points[0].x == _rhs.points[0].x && points[0].y == _rhs.points[0].y 
                      && points[1].x == _rhs.points[1].x && points[1].y == _rhs.points[1].y)
                || (points[0].x == _rhs.points[1].x && points[0].y == _rhs.points[1].y
                    && points[1].x == _rhs.points[0].x && points[1].y == _rhs.points[0].y);
            };
    };

    class RoadTileManager_impl;
    
    class RoadTile {
    public:
        RoadTile(TileID tileId) : tileId(tileId) { };
        std::multimap<MercPoint, std::shared_ptr<RoadSegment>, MercPointComparator> roads;
        std::multimap<MercPoint, std::shared_ptr<RoadSegment>, MercPointComparator> reverseRoads;
        TileID tileId;
        
        void pushRoad(shared_ptr<RoadSegment> road);
    private:
        // RoadTile Cache management
        friend class RoadTileManager_impl;
        shared_ptr<RoadTile> prev;
        shared_ptr<RoadTile> next;
    };
    
    class RoadTileRequester {
    public:
        virtual void onTileArrival(const std::shared_ptr<RoadTile>& tile) = 0;
    };
    
    class RoadTileManager {
    public:
        static std::shared_ptr<RoadTileManager> getManager();
        void collectTile(const TileID& tileIdToSearch,
                          std::shared_ptr<RoadTileRequester> requester);

        const shared_ptr<RoadTile>& getTileInCache(const TileID& tileId);
        
        /** @brief 필요한 타일을 요청하고 이를 가져오는 역할을 하는 객체
         *  @param type         tile의 형태 (e.g. MVT, togoJson)
         *  @param urlTemplate  tile을 가져올 때 url의 template
         *
         *  @discussion 현재는 singleton으로 정의되어 있어서 private으로 지정
         */
        RoadTileManager();

    private:
        std::unique_ptr<RoadTileManager_impl> impl;        
    };
}

void delegateToMainThread(std::function<void(void)> func);

#endif /* RoadTileManager_h */
