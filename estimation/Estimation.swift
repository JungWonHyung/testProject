//
//  Estimation.swift
//  tangram
//
//  Created by jung-wonhyung on 2018. 6. 21..
//

import Foundation

class Estimation {
    static let shared = Estimation()
    var realData : [SimulatedLocationData] = []
    var estimationData : [ELocation] = []
    var roadSegment : [CLLocationCoordinate2D] = []//[RoadSegment] = []
    
    private var originCoordinate : SimulatedLocationData? = nil
    private init(){}
    
    func setRoadSegment(){
        
    }
    
    func setRealData(data : [SimulatedLocationData]){
        realData = data
    }
    
    func estimate()-> [ELocation] {
        //var timeDelta = 0.0
        //var direction = 0.0
        //var speed = 0.0 // (m/s)
        
        
        return estimationData
    }
    
    func getRealLocation(time : TimeInterval)->CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: realData[0].lat, longitude: realData[0].lng)
    }
    
    func getDirection(){
        
    }
    
    func checkGyro()-> Bool{
        return false
    }
}

struct ELocation {
    var isReal : Bool
    var coordnate : CLLocationCoordinate2D
    var time : TimeInterval
}
