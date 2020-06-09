//
//  ViewController.swift
//  FindWay_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-09.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController {

    @IBOutlet weak var mapObject: MKMapView!
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpMapView()
    }

    func setUpMapView() {
           mapObject.showsUserLocation = true
           mapObject.showsCompass = true
           mapObject.showsScale = true
           currentLocation()
        }
        
        //MARK: - Helper Method
        func currentLocation() {
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           if #available(iOS 11.0, *) {
              locationManager.showsBackgroundLocationIndicator = true
           } else {
              // Fallback on earlier versions
           }
           locationManager.startUpdatingLocation()
        }

}
extension ViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        mapObject.setRegion(coordinateRegion, animated: true)
//        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Occured: \(error.localizedDescription)")
     }
}
