//
//  ViewController.swift
//  FindWay_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-09.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapObject: MKMapView!
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    var tappedLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         mapObject.delegate = self
        // map intialzing
        setUpMapView()
        
        // handle double tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    @objc func doubleTapped(gestureRecognizer: UITapGestureRecognizer)
    {
        let location = gestureRecognizer.location(in: mapObject)
        self.tappedLocation = mapObject.convert(location, toCoordinateFrom: mapObject)
        
        //annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.tappedLocation!
        annotation.title = "Location Tapped"
        annotation.subtitle = "Your Desired Location"
        // custom annotation
        mapObject.addAnnotation(annotation)
    }

    func setUpMapView() {
            mapObject.showsUserLocation = true
            mapObject.showsCompass = true
            mapObject.showsScale = true
            mapObject.isZoomEnabled = false
            mapObject.isScrollEnabled = true
        
        // pin points
//        let artwork1 = Artwork(
//            title: "Location",
//            locationName: "Your Assigned Location",
//            discipline: "Location",
//            coordinate: CLLocationCoordinate2D(latitude:
//                40.7580, longitude: -73.9855))
//        let artwork2 = Artwork(
//                   title: "Trinity",
//                   locationName: "Trinity Square Mall",
//                   discipline: "Mall",
//                   coordinate: CLLocationCoordinate2D(latitude:
//                       43.7321, longitude: -79.7660))
//            mapObject.addAnnotation(artwork1)
//            mapObject.addAnnotation(artwork2)

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

    @IBAction func findMyWay(_ sender: UIButton) {
//        print("Find My Way")
        let sourceLat = mapObject.userLocation.location!.coordinate.latitude
        let sourceLong = mapObject.userLocation.location!.coordinate.longitude
        let destinationLat = self.tappedLocation!.latitude
        let destinationLong = self.tappedLocation!.longitude
        print("Source: \(sourceLat) , \(sourceLong)")
        print("Destination: \(destinationLat) , \(destinationLong)")
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong), addressDictionary: nil))
               request.requestsAlternateRoutes = true
        request.transportType = .walking

               let directions = MKDirections(request: request)

               directions.calculate { [unowned self] response, error in
                   guard let unwrappedResponse = response else { return }

                   for route in unwrappedResponse.routes {
                       self.mapObject.addOverlay(route.polyline)
                       self.mapObject.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                   }
               }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
               return renderer
    }
    
}
extension ViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        mapObject.setRegion(coordinateRegion, animated: true)
        //locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Occured: \(error.localizedDescription)")
     }
}
