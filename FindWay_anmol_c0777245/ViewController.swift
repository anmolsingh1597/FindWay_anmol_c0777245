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
        
        // Map intialzing
        setUpMapView()
        
        // handle double tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc func doubleTapped(gestureRecognizer: UILongPressGestureRecognizer)
    {
        print("Double tapped")
        let location = gestureRecognizer.location(in: mapObject)
        let coordinate = mapObject.convert(location, toCoordinateFrom: mapObject)

        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapObject.addAnnotation(annotation)
    }

    func setUpMapView() {
            mapObject.showsUserLocation = true
            mapObject.showsCompass = true
            mapObject.showsScale = true
            mapObject.isZoomEnabled = false
        
        // pin points
        let artwork1 = Artwork(
            title: "Location",
            locationName: "Your Assigned Location",
            discipline: "Location",
            coordinate: CLLocationCoordinate2D(latitude:
                40.7580, longitude: -73.9855))
        let artwork2 = Artwork(
                   title: "Trinity",
                   locationName: "Trinity Square Mall",
                   discipline: "Mall",
                   coordinate: CLLocationCoordinate2D(latitude:
                       43.7321, longitude: -79.7660))
            mapObject.addAnnotation(artwork1)
            mapObject.addAnnotation(artwork2)

        
        // call for current location
           currentLocation()
        }
        
        func currentLocation() {
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           if #available(iOS 11.0, *) {
              locationManager.showsBackgroundLocationIndicator = true
           } else {
              // code for earlier version
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
