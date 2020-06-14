//
//  ViewController.swift
//  FindWay_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-09.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate, UITabBarDelegate, UITabBarControllerDelegate{
    
    //MARK: Zoom in zoom out button deprecated because stepper for zoom in zoom out integrated
//    @IBOutlet weak var zoomInBtn: UIButton!
//    @IBOutlet weak var zoomOutBtn: UIButton!
    
    @IBOutlet weak var mapObject: MKMapView!
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    var tappedLocation: CLLocationCoordinate2D?
    @IBOutlet weak var findMyWayBtn: UIButton!
    @IBOutlet weak var routeTabBar: UITabBar!
    @IBOutlet weak var zoomStepper: UIStepper!
    
    
    var stepperComparingValue = 0.0
    
    let request = MKDirections.Request()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            mapObject.delegate = self
        // map intialzing
            setUpMapView()
        //find my way button attribute
            findMyWayBtn.layer.cornerRadius = 38
            findMyWayBtn.layer.borderWidth = 1
            findMyWayBtn.layer.borderColor = UIColor.white.cgColor
            findMyWayBtn.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
            findMyWayBtn.heightAnchor.constraint(equalToConstant: 75.0).isActive = true

        //route tab bar requested route and visibility
            routeTabBar.delegate = self
        // handle double tap
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            view.addGestureRecognizer(tap)
    }
    
    //MARK: double tap function
    @objc func doubleTapped(gestureRecognizer: UITapGestureRecognizer)
    {
        // remove all annotations(markers)
        let allAnnotations = self.mapObject.annotations
        self.mapObject.removeAnnotations(allAnnotations)
        //remove overlays
        mapObject.removeOverlays(mapObject.overlays)
        //location finder with double tap
        let location = gestureRecognizer.location(in: mapObject)
        self.tappedLocation = mapObject.convert(location, toCoordinateFrom: mapObject)
        
        //annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.tappedLocation!
        annotation.title = "Location Tapped"
        annotation.subtitle = "Your Desired Location"
        // custom annotation
        mapObject.addAnnotation(annotation)
        routeTabBar.isHidden = true
        findMyWayBtn.isHidden = false
    }
    
    //MARK:- Stepper value change
    @IBAction func zoomStepperValueChange(_ sender: UIStepper) {

        let stepperValue = zoomStepper.value
        if(stepperValue > self.stepperComparingValue){

            var region: MKCoordinateRegion = mapObject.region
            region.span.latitudeDelta /= 2.0
            region.span.longitudeDelta /= 2.0
            mapObject.setRegion(region, animated: true)
            self.stepperComparingValue = stepperValue
        }else if(stepperValue < self.stepperComparingValue){

            var region: MKCoordinateRegion = mapObject.region
              region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
              region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
              mapObject.setRegion(region, animated: true)
            self.stepperComparingValue = stepperValue
        }
    }
    
//MARK: setting up map
    func setUpMapView() {
            mapObject.showsUserLocation = true
            mapObject.showsCompass = true
            mapObject.showsScale = true
            mapObject.isZoomEnabled = false
            mapObject.isScrollEnabled = true
        // call for current location
           currentLocation()
        }
        
    //MARK: current location
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
    
    //MARK: find my way
    @IBAction func findMyWay(_ sender: UIButton) {

            let sourceLat = mapObject.userLocation.location?.coordinate.latitude ?? 0.00
            let sourceLong = mapObject.userLocation.location?.coordinate.longitude ?? 0.00
            let destinationLat = self.tappedLocation?.latitude ?? 0.00
            let destinationLong = self.tappedLocation?.longitude ?? 0.00
            print("Source: \(sourceLat) , \(sourceLong)")
            print("Destination: \(destinationLat) , \(destinationLong)")
                if(sourceLat == 0.0 || sourceLong == 0.0){
                    let alert = UIAlertController(title: "Location couldn't retrieve!!", message: "Simulate Location from your xcode", preferredStyle: UIAlertController.Style.alert)
                                  alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                  self.present(alert, animated: true, completion: nil)
            }
                else if(destinationLat == 0.0 || destinationLong == 0.0){
                    let alert = UIAlertController(title: "Alert", message: "Please double tap to select destination", preferredStyle: UIAlertController.Style.alert)
                       alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                       self.present(alert, animated: true, completion: nil)
                }else{
        
        let alert = UIAlertController(title: "Choose!!", message: "Please select the route type", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Walking", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

            self.routeTabBar.selectedItem = self.routeTabBar.items?[0]
            self.request.transportType = .walking
            self.routeFinder()
        }))
        alert.addAction(UIAlertAction(title: "Automobile", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

            self.routeTabBar.selectedItem = self.routeTabBar.items?[1]
                self.request.transportType = .automobile
                self.routeFinder()
               }))
        self.present(alert, animated: true, completion: nil)
   
        }
        }
    
    //MARK: func route variation
    func routeFinder(){
        //source and destination lat and long
        let sourceLat = mapObject.userLocation.location?.coordinate.latitude ?? 0.00
        let sourceLong = mapObject.userLocation.location?.coordinate.longitude ?? 0.00
        let destinationLat = self.tappedLocation?.latitude ?? 0.00
        let destinationLong = self.tappedLocation?.longitude ?? 0.00
        print("Source: \(sourceLat) , \(sourceLong)")
        print("Destination: \(destinationLat) , \(destinationLong)")
            routeTabBar.isHidden = false
            findMyWayBtn.isHidden = true
            // request globally declared
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong), addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong), addressDictionary: nil))
            request.requestsAlternateRoutes = true
               

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self.mapObject.addOverlay(route.polyline)
                        self.mapObject.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
    }
    
    //MARK: map view delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if self.request.transportType == .automobile
        {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        renderer.alpha = 0.80
            return renderer
            
        }else if self.request.transportType == .walking {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.red
            renderer.lineDashPattern = [5, 10]
            renderer.lineWidth = 5.0
            renderer.alpha = 0.80
            return renderer
        }
        
        return MKOverlayRenderer()
    }
   
    //MARK: route tab bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item == routeTabBar.items?[0]){
            //remove overlays
            mapObject.removeOverlays(mapObject.overlays)
            self.request.transportType = .walking
            routeTabBar.selectedItem = routeTabBar.items?[0]
            routeFinder()
        }else if(item == routeTabBar.items?[1]){
            //remove overlays
            mapObject.removeOverlays(mapObject.overlays)
            self.request.transportType = .automobile
            routeTabBar.selectedItem = routeTabBar.items?[1]
            routeFinder()
        }
    }
    
    // Zoom In button
//    @IBAction func zoomInButton(_ sender: UIButton) {
//        var region: MKCoordinateRegion = mapObject.region
//        region.span.latitudeDelta /= 2.0
//        region.span.longitudeDelta /= 2.0
//        mapObject.setRegion(region, animated: true)
//    }
    
    // Zoom Out Buttom
//    @IBAction func zoomOutButton(_ sender: UIButton) {
//    var region: MKCoordinateRegion = mapObject.region
//    region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
//    region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
//    mapObject.setRegion(region, animated: true)
//    }
    
}

//MARK: extension for location manager
extension ViewController: CLLocationManagerDelegate {
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 15000, longitudinalMeters: 15000)
        mapObject.setRegion(coordinateRegion, animated: true)
        // automatically updates location
        locationManager.stopUpdatingLocation()
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error Occured: \(error.localizedDescription)")
     }
}
