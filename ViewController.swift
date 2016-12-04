//
//  ViewController.swift
//  Bike Travel
//
//  Created by Kyle Brown on 12/3/16.
//  Copyright © 2016 Kyle Brown. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController ,CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    let manager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Center Location = Full View Of Purdue University
        let centerLocation = CLLocationCoordinate2DMake(40.424,-86.9200)
                
        let mapSpan = MKCoordinateSpanMake(0.03, 0.03)
        
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        self.map.setRegion(mapRegion, animated: true)
        
        //var annotation = MKPointAnnotation()
        
        //Todo Fix to make a annotation
        //annotation.coordinate(centerLocation)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

