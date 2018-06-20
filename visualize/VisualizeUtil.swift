//
//  VisualizeUtil.swift
//  tangram
//
//  Created by jung-wonhyung on 2018. 6. 19..
//

import Foundation

class VisualizeUtil {
    
    func getHexColor(hex : String, alpha : CGFloat)-> UIColor{
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = alpha
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return UIColor(red: 0, green: 0, blue: 0, alpha: 1) }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func readDataFile(fileName : String, fileExtension : String) ->String {
        var fileString : String? = nil
        let file = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        do{
            let data = try Data(contentsOf: file!)
            fileString = String(data: data, encoding: String.Encoding.utf8)
            return fileString ?? ""
        }catch{
            print(error)
            assert(false)
        }
    }
    
    func errorMessage(message : String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction!)in
        })
        alert.addAction(okAction)
        
        MapViewController.shared().present(alert,animated: true, completion: nil)
    }
    func makeMarker_path(locationList : [SimulatedLocationData], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        let locationPointer : UnsafeMutablePointer<SimulatedLocationData> = UnsafeMutablePointer(mutating: locationList)
        
        mapViewController?.showPath(Int32(locationList.count), color: color, simulatedLocationDatas: locationPointer)
        mapViewController?.goLocation(CLLocationCoordinate2D(latitude: locationList[0].lat, longitude: locationList[0].lng))
    }
    
    func makeMarker_path(locationList : [CLLocationCoordinate2D], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        
        let locationPointer : UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(mutating: locationList)
        mapViewController?.showPath(Int32(locationList.count), color: color, cLLocationCoordinate2Ds: locationPointer)
        mapViewController?.goLocation(locationList.first!)
    }
    
    func makePolyline(locationList : [CLLocationCoordinate2D], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        
        let locationPointer : UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(mutating: locationList)
        mapViewController?.makeMarker_polyline(Int32(locationList.count), color: color, cLLocationCoordinate2Ds: locationPointer)
        mapViewController?.goLocation(locationList.first!)
    }
    
    func makePolyline(locationList : [SimulatedLocationData], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        
        let locationPointer : UnsafeMutablePointer<SimulatedLocationData> = UnsafeMutablePointer(mutating: locationList)
        mapViewController?.makeMarker_polyline(Int32(locationList.count), color: color, simulatedLocationDatas: locationPointer)
        mapViewController?.goLocation(CLLocationCoordinate2D(latitude: locationList[0].lat, longitude: locationList[0].lng))
    }
    
    func makePoints(locationList : [CLLocationCoordinate2D], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        
        let locationPointer : UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(mutating: locationList)
        mapViewController?.makeMarker_points(Int32(locationList.count), color: color, cLLocationCoordinate2Ds: locationPointer)
        mapViewController?.goLocation(locationList.first!)
    }
    
    func makePoints(locationList : [SimulatedLocationData], color : String = "0ed864"){
        let mapViewController = MapViewController.shared()
        
        let locationPointer : UnsafeMutablePointer<SimulatedLocationData> = UnsafeMutablePointer(mutating: locationList)
        mapViewController?.makeMarker_points(Int32(locationList.count), color: color, simulatedLocationDatas: locationPointer)
        mapViewController?.goLocation(CLLocationCoordinate2D(latitude: locationList[0].lat, longitude: locationList[0].lng))
    }
}
