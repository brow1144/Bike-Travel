//
//  ViewController.swift
//  Bike Travel
//
//  Created by Kyle Brown on 12/3/16.
//  Copyright © 2016 Kyle Brown. All rights reserved.
//


/*
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
 
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var calculateRoute: UIToolbar!
    let manager = CLLocationManager()
    
    //Current Location Method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
                
        self.map.showsUserLocation = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding Current Location Functionality
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}
 */
import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    
    var myRoute : MKRoute!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let point1 = MKPointAnnotation()
        let point2 = MKPointAnnotation()
        
        point1.coordinate = CLLocationCoordinate2DMake(40.4267, -86.9267)
        point1.title = "Elliot Hall of Music"
        //point1.subtitle = "Taiwan"
        myMap.addAnnotation(point1)
        
        point2.coordinate = CLLocationCoordinate2DMake(40.4277, -86.9170)
        point2.title = "Lawson Computer Science"
        //point2.subtitle = "Taiwan"
        myMap.addAnnotation(point2)
        myMap.centerCoordinate = point2.coordinate
        myMap.delegate = self
        
        //Span of the map
        myMap.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.03,0.03)), animated: true)
        
        let directionsRequest = MKDirectionsRequest()
        let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
        let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: markChungli)
        directionsRequest.destination = MKMapItem(placemark: markTaipei)
        
        directionsRequest.transportType = MKDirectionsTransportType.walking
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate(completionHandler: {
            response, error in
            
            if error == nil {
                self.myRoute = response!.routes[0] as MKRoute
                self.myMap.add(self.myRoute.polyline)
            }
            
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor = UIColor.green
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

