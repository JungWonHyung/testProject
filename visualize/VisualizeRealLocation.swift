//
//  VisualizeRealLocation.swift
//  tangram
//
//  Created by jung-wonhyung on 2018. 6. 19..
//

import Foundation

class VisualizeRealLocation {
    func showDataFile(fileName: String,fileExtension: String, pointColor: String = "0ed864", polylineColor: String = "0ed864"){
        let data = VisualizeUtil().readDataFile(fileName: fileName, fileExtension: fileExtension)
        showDataString(data: data, pointColor: pointColor, polylineColor: polylineColor)
    }
    
    func showDataString(data : String, pointColor: String = "0ed864", polylineColor: String = "0ed864") {
        let locationList = jsonDeserializationJson_simulatedLocations(dataString: data)
        if locationList.count == 0 {
            return
        }
        
        VisualizeUtil().makePolyline(locationList: locationList, color: polylineColor)
        VisualizeUtil().makePoints(locationList: locationList, color: pointColor)
        print("========================================timestamp============================================")
        var preLcation : Double = locationList[0].timestamp;
        for loc in locationList{
            print(loc.timestamp - preLcation)
            preLcation = loc.timestamp
        }
        print("=============================================================================================")

        let mapViewController = MapViewController.shared()
        mapViewController?.goLocation(CLLocationCoordinate2D(latitude: locationList[0].lat, longitude: locationList[0].lng))
    }
    
    
    func jsonDeserializationJson_simulatedLocations(dataString : String)-> [SimulatedLocationData] {
        
        var result : [SimulatedLocationData] = []
        
        guard let data = dataString.data(using: String.Encoding.utf8) else {
            VisualizeUtil().errorMessage(message: "getPlanLogs typecasting err - string to data")
            return []
        }
        
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as! [Any] else {
            VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to jsonSerialization")
            return []
        }
        
        for loc in jsonData{
            guard let location = loc as? [String : Any] else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to loc")
                return []
            }
            guard let coordinate = location["coordinate"] as? [String : Any] else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to coordinate")
                return []
                
            }
            guard let lat = coordinate["lat"] as? Double, let lng = coordinate["lng"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to lat lng")
                return []
                
            }
            if lat == 300 || lng == 300 {
                break;
            }
            guard let altitude = location["altitude"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to altitude")
                return []
                
            }
            guard let horizontalAccuracy = location["horizontalAccuracy"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to horizontalAccuracy")
                return []
                
            }
            guard let verticalAccuracy = location["verticalAccuracy"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to verticalAccuracy")
                return []
                
            }
            guard let course = location["course"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to course")
                return []
                
            }
            guard let speed = location["speed"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to speed")
                return []
                
            }
            guard let timestamp = location["timestamp"] as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to timestamp")
                return []
            }
            guard let m11 = location["m11"] as? Double, let m12 = location["m12"] as? Double, let m13 = location["m13"] as? Double,
                let m21 = location["m21"] as? Double, let m22 = location["m22"] as? Double, let m23 = location["m23"] as? Double,
                let m31 = location["m31"] as? Double, let m32 = location["m32"] as? Double, let m33 = location["m33"] as? Double else{
                    VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to metrix")
                    return []
            }
            
            guard let quaternion_x = location["quaternion_x"]as? Double, let quaternion_y = location["quaternion_y"]as? Double, let quaternion_z = location["quaternion_z"]as? Double, let quaternion_w = location["quaternion_w"]as? Double else {
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to quaternion")
                return []
            }
            
            guard let x = location["x"] as? Double, let y = location["y"] as? Double, let z = location["z"] as? Double else{
                VisualizeUtil().errorMessage(message: "Location_Simulator : jsonDeserializationJson_simulatedLocations : fail to gravity")
                return []
            }
            
            let one = SimulatedLocationData(lat: lat, lng: lng, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp, m11: m11, m12: m12, m13: m13, m21: m21, m22: m22, m23: m23, m31: m31, m32: m32, m33: m33, x: x, y: y, z: z, quaternion_x: quaternion_x, quaternion_y: quaternion_y, quaternion_z: quaternion_z, quaternion_w: quaternion_w)
            
            result.append(one)
        }
        
        return result
    }
}

/*
struct SimulatedLocationData {
    var lat:Double;
    var lng:Double;
    var altitude:Double;
    var horizontalAccuracy:Double;
    var verticalAccuracy:Double;
    var course:Double;
    var speed:Double;
    var timestamp:Double;
    
    
    // about rotationMatrix from motion
    var m11:Double;
    var m12:Double;
    var m13:Double;
    var m21:Double;
    var m22:Double;
    var m23:Double;
    var m31:Double;
    var m32:Double;
    var m33:Double;
    
    //about gravity from motion
    var x:Double;
    var y:Double;
    var z:Double;
    
    //about quaternion from motion
    var quaternion_x:Double;
    var quaternion_y:Double;
    var quaternion_z:Double;
    var quaternion_w:Double;
}
 */

