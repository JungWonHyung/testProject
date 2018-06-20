//
//  MainViewController.swift
//  tangram
//
//  Created by jung-wonhyung on 2018. 6. 19..
//

import UIKit

class VisualizeMainViewController: UIViewController {
    @IBOutlet var pointColorField: UITextField!
    
    @IBOutlet var polylineColorField: UITextField!

    @IBOutlet var typeField: UITextField!
    @IBOutlet var scriptText: UITextView!
    @IBOutlet var mapView: UIView!
    @IBOutlet var toolBox: UIView!
    var mapViewController : MapViewController!

    override func loadView() {
        super.loadView()
        mapViewController = MapViewController.shared()
        mapView.addSubview(mapViewController.view)
        self.addChildViewController(mapViewController)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBox.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //button action
    @IBAction func toolShow(_ sender: UIButton) {
        toolBox.isHidden = !toolBox.isHidden
    }
    
    @IBAction func removeAllAction(_ sender: UIButton) {
        // remove all marker
        mapViewController.markerRemoveAll()
        mapViewController.mapData.clear()
    }
    
    @IBAction func runAction(_ sender: UIButton) {
        // run script
        print(typeField.text)
        print(pointColorField.text)
        print(polylineColorField.text)
        print(scriptText.text)
        
        switch typeField.text?.lowercased() {
        case "rd":  // real data
            let pointColor = pointColorField.text ?? "0ed864"
            let polylineColor = polylineColorField.text ?? "0ed864"
            if scriptText.text == ""{
                VisualizeRealLocation().showDataFile(fileName: "locationSimulator_test", fileExtension: "sim", pointColor: pointColor, polylineColor: polylineColor)
            }else {
                VisualizeRealLocation().showDataString(data: scriptText.text, pointColor: pointColor, polylineColor: polylineColor)
            }
        case "go":  // move mapView location
            if let location = scriptText.text { //nead text : [lat<Double>,lng<Double>]  ex) [37.612449, 126.833508]
                let data = location.data(using: .utf8)!
                guard let lnglat = try? JSONSerialization.jsonObject(with: data, options: []) as! [Double] else {
                    return
                }
                mapViewController.goLocation(CLLocationCoordinate2D(latitude: lnglat[0], longitude: lnglat[1]))
            }
        default:
            return
        }
    }
}
