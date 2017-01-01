//
//  ViewController.siwft
//  Bike Travel
//
//
//  Created by Kyle Brown on 12/3/16.
//  Copyright © 2016 Kyle Brown. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //UI Variables
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeSubLabel: UILabel!
    @IBOutlet weak var distanceSubLevel: UILabel!
    @IBOutlet weak var timeBoxButton: UIButton!
    @IBOutlet weak var distanceBox: UIImageView!
    @IBOutlet weak var speedLabel: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var calculate: UIBarButtonItem!
    @IBOutlet var arrowImage: UIImageView!
    @IBOutlet var windBackground: UIImageView!
        
    //User Location Variable
    let manager = CLLocationManager()

    //Map Annotations and Routes
    var myRoute : MKRoute!
    var pinAnnotationView : MKPinAnnotationView!
    var annotation:MKAnnotation!
    var pointAnnotation : MKPointAnnotation!
    var myLocation : CLLocationCoordinate2D!
    var directions : MKDirections!
    var myLineRenderer : MKPolylineRenderer!
    
    //Slider Value (Default is 9.8mph)
    var sliderValue : Double = 9.8
    
    //Weather Variables
    let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    let openWeatherMapAPIKey = "2a0e4c51a24010f830e178e810f59517"
    var speed : String!
    var direction : String!
    var weatherRequestURL : NSURL!
    
    //Time Variables 
    var hours : String!
    var minutes : String!
    var seconds : String!
    
    //Recieve Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     
    Opening App Tasks
     
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myMap.delegate = self
        
        //Make Calculate Route Button Un-Clickable 
        self.calculate.isEnabled = false
        
        //Make Arrow Image Invisible
        self.arrowImage.image = nil
        
        //Sets Slider To Be Able To Slide
        self.slider.isEnabled = true
        
        //Make Time and Distance Box Invisible When Launched
        self.timeBoxButton.setImage(nil, for: .normal)
        self.distanceBox.image = nil
        
        //Make Wind Box Invisible
        self.windBackground.image = nil
        
        //User Location Set-Up
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
      
        notifications()
      
        //Long Press Set-Up
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.myMap.addGestureRecognizer(longPressGesture)
    }
  
  /**
   Setting Up User Notifications
   
   */
  func notifications() {
    
    //User Notifications Set-Up
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
    
    //User Notifications
    let content = UNMutableNotificationContent()
    content.title = "It's been a while!"
    content.subtitle = "Wana go for a bike ride?"
    content.body = "Switch over to Bike Travel to get the most accurate bike travel time and current speed while on the bike ride!"
    content.badge = 1
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
    let request = UNNotificationRequest(identifier: "Come Back!", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }
  
    /**
     Finding User Location
     
     - Parameter gesture:   UILong Press Recognizer
     
     */
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        //Remove All Time and Distance Information
        self.timeBoxButton.setImage(nil, for: .normal)
        self.distanceBox.image = nil
        self.timeLabel.text = nil
        self.distanceLabel.text = nil
        self.timeSubLabel.text = nil
        self.distanceSubLevel.text = nil
        
        //Remove Map Overlays
        let overlays = myMap.overlays
        myMap.removeOverlays(overlays)
        
        //Remove All Previous Map Annotations
        if (pointAnnotation != nil) {
            myMap.removeAnnotation(pointAnnotation)
        }
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.myMap)
            let coordinate = self.myMap.convert(point, toCoordinateFrom: self.myMap)

            //let annotation = MKPointAnnotation()
            self.pointAnnotation = MKPointAnnotation()

            self.pointAnnotation.coordinate = coordinate
            //Set title and subtitle if you want
            self.pointAnnotation.title = "Title"
            self.pointAnnotation.subtitle = "subtitle"
            self.myMap.addAnnotation(self.pointAnnotation)
            
            //Allow To Calculate
            self.calculate.isEnabled = true
        }
    }
    
    /**
     Finding User Location
     
     - Parameter manager:   CLLocationManager that Finds Users.
     - Parameter locations: Array of Locaitons used to find lat / long / etc.
     
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Finds User Location and Show
        let location = locations[0]
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        myMap.setRegion(region, animated: true)
        self.myMap.showsUserLocation = true
   
        //Create URL
        weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(openWeatherMapAPIKey)")!
        
        //Allow User To Move off User Location
        manager.stopUpdatingLocation()
        
        //Call To Get Weather
        getWeather(city: "wheatfield,in")
        
    }
    
    /**
     Draws on Map View
     
     - Parameter mapView:   MKMapView to be Added to.
     - Parameter overlay:   Overlays to be added to the Map.
     
     - Returns: MKOverlayRenderer 
     
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //Draws and Changes Route Characteristics
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor = UIColor.green
        myLineRenderer.lineWidth = 3
        return myLineRenderer
        
    }
    
    /**
     Action for when the Slider is Moved
     
     - Parameter sender:   Access to the UISlider
     
     */
    @IBAction func sliderMoved(_ sender: UISlider) {
        self.sliderValue = Double(sender.value)
        self.speedLabel.title = ("\(Int(sender.value))" + " mph")
    }
    
    /**
     Method To Retireve Weather Data From Open Weather API
     
     - Parameter String:    String of City Name
     
    */
    func getWeather(city: String) {
        
        // Simple Network Task
        let session = URLSession.shared
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                // Error While Trying to get Data For Weather
                print("Error:\n\(error)")
            }
            else {
                // Response Worked!
                do {
                    // Convert that data into a Swift dictionary
                    let weather = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]
                    
                    // Print Contents Console.
                    
                    /*
                    print("Date and time: \(weather["dt"]!)")
                    print("City: \(weather["name"]!)")
                    
                    print("Longitude: \(weather["coord"]!["lon"]!!)")
                    print("Latitude: \(weather["coord"]!["lat"]!!)")
                    
                    print("Temperature: \(weather["main"]!["temp"]!!)")
                    print("Humidity: \(weather["main"]!["humidity"]!!)")
                    print("Pressure: \(weather["main"]!["pressure"]!!)")
                    
                    print("Cloud cover: \(weather["clouds"]!["all"]!!)")
                    
                    print("Country: \(weather["sys"]!["country"]!!)")
                    print("Sunrise: \(weather["sys"]!["sunrise"]!!)")
                    print("Sunset: \(weather["sys"]!["sunset"]!!)")

                    print("Wind direction: \(weather["wind"]!["deg"]!!) degrees")
                    print("Wind speed: \(weather["wind"]!["speed"]!!)")
                    */
                
                    //Set speed
                    let x = weather["wind"]!["speed"]!
                    self.speed = String(describing: x!)
                    let speedTwo = Double(round(100 * Double(self.speed)!) / 100)

                    
                    //Set Direction In Degrees
                    let y = weather["wind"]!["deg"]!
                    self.direction = String(describing: y!)
                    
                    //Make Wind Data Panel Visible
                    DispatchQueue.main.async {
                        self.windBackground.image = #imageLiteral(resourceName: "ace")
                        self.windLabel.text = String(describing: speedTwo) + " mph"
                        
                        //Takes Direction Degrees and Changes to Direction Symbol
                        //Also Adds An Arrow To The Top Right To Show Direction
                        if (Double(self.direction)! > 348.75 || Double(self.direction)! < 11.25) {
                            self.directionLabel.text = "N"
                            self.arrowImage.image = #imageLiteral(resourceName: "Narrow")
                        } else if (Double(self.direction)! >= 11.25 && Double(self.direction)! < 33.75) {
                            self.directionLabel.text = "NNE"
                            self.arrowImage.image = #imageLiteral(resourceName: "NNEarrow")
                        } else if (Double(self.direction)! >= 33.75 && Double(self.direction)! < 56.25) {
                            self.directionLabel.text = "NE"
                            self.arrowImage.image = #imageLiteral(resourceName: "NEarrow")
                        } else if (Double(self.direction)! >= 56.25 && Double(self.direction)! < 78.75) {
                            self.directionLabel.text = "ENE"
                            self.arrowImage.image = #imageLiteral(resourceName: "ENEarrow")
                        } else if (Double(self.direction)! >= 78.75 && Double(self.direction)! < 101.25) {
                            self.directionLabel.text = "E"
                            self.arrowImage.image = #imageLiteral(resourceName: "Earrow")
                        } else if (Double(self.direction)! >= 101.25 && Double(self.direction)! < 123.75) {
                            self.directionLabel.text = "ESE"
                            self.arrowImage.image = #imageLiteral(resourceName: "ESEarrow")
                        } else if (Double(self.direction)! >= 123.75 && Double(self.direction)! < 146.25) {
                            self.directionLabel.text = "SE"
                            self.arrowImage.image = #imageLiteral(resourceName: "SEarrow")
                        } else if (Double(self.direction)! >= 146.25 && Double(self.direction)! < 168.75) {
                            self.directionLabel.text = "SSE"
                            self.arrowImage.image = #imageLiteral(resourceName: "SSEarrow")
                        } else if (Double(self.direction)! >= 168.75 && Double(self.direction)! < 191.25) {
                            self.directionLabel.text = "S"
                            self.arrowImage.image = #imageLiteral(resourceName: "Sarrow")
                        } else if (Double(self.direction)! >= 191.25 && Double(self.direction)! < 213.75) {
                            self.directionLabel.text = "SSW"
                            self.arrowImage.image = #imageLiteral(resourceName: "SSWarrow")
                        } else if (Double(self.direction)! >= 213.75 && Double(self.direction)! < 236.75) {
                            self.directionLabel.text = "SW"
                            self.arrowImage.image = #imageLiteral(resourceName: "SWarrow")
                        } else if (Double(self.direction)! >= 236.75 && Double(self.direction)! < 258.75) {
                            self.directionLabel.text = "WSW"
                            self.arrowImage.image = #imageLiteral(resourceName: "WSWarrow")
                        } else if (Double(self.direction)! >= 258.75 && Double(self.direction)! < 281.25) {
                            self.directionLabel.text = "W"
                            self.arrowImage.image = #imageLiteral(resourceName: "Warrow")
                        } else if (Double(self.direction)! >= 281.25 && Double(self.direction)! < 303.75) {
                            self.directionLabel.text = "WNW"
                            self.arrowImage.image = #imageLiteral(resourceName: "WNWarrow")
                        } else if (Double(self.direction)! >= 303.75 && Double(self.direction)! < 326.25) {
                            self.directionLabel.text = "NW"
                            self.arrowImage.image = #imageLiteral(resourceName: "NWarrow")
                        } else if (Double(self.direction)! >= 326.25 && Double(self.direction)! < 348.75) {
                            self.directionLabel.text = "NNW"
                            self.arrowImage.image = #imageLiteral(resourceName: "NNWarrow")
                        }
                    
                    
                        //Color Palet
                        let myGreenColor = UIColor(
                            red:26.0/255.0,
                            green:230.0/255.0,
                            blue:23.0/255.0,
                            alpha:1.0)
                    
                        let myYellowColor = UIColor(
                            red:255.0/255.0,
                            green:245.0/255.0,
                            blue:0.0/255.0,
                            alpha:1.0)
                    
                        let myRedColor = UIColor(
                            red:255.0/255.0,
                            green:0.0/255.0,
                            blue:0.0/255.0,
                            alpha:1.0)
                    
                        //Chaning Color Depending On Speed
                        if (Double(self.speed)! < 8.0) {
                            self.windLabel.textColor = myGreenColor
                            self.directionLabel.textColor = myGreenColor
                        } else if (Double(self.speed)! < 18.0) {
                            self.windLabel.textColor = myYellowColor
                            self.directionLabel.textColor = myYellowColor
                        } else if (Double(self.speed)! > 20.0) {
                            self.windLabel.textColor = myRedColor
                            self.directionLabel.textColor = myRedColor
                        }
                    }
                    
                } catch let jsonError as NSError {
                    // Error occurred while trying to convert the data into a Swift dictionary.
                    
                    print("JSON error description: \(jsonError.description)")
                }
            }
        }
        // Resume
        dataTask.resume()
    }
  
    /**
     Called When user is Finished Typing and hits Route
     
     - Parameter sender:   Access to the UITextField
     
     */
    @IBAction func textFieldShouldReturn(_ sender: UITextField) {
        
        //Remove All Previous Map Annotations
        if (pointAnnotation != nil) {
            myMap.removeAnnotation(pointAnnotation)
        }
  
        //Remove All Time and Distance Information
        self.timeBoxButton.setImage(nil, for: .normal)
        self.distanceBox.image = nil
        self.timeLabel.text = nil
        self.distanceLabel.text = nil
        self.timeSubLabel.text = nil
        self.distanceSubLevel.text = nil
        
        //Remove Map Overlays
        let overlays = myMap.overlays
        myMap.removeOverlays(overlays)
        
        //Find Location Entered By User
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            //Place Not Found Dialog Box
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //Annotate Map at User Inputed Location
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.myMap.centerCoordinate = self.pointAnnotation.coordinate
            self.myMap.addAnnotation(self.pinAnnotationView.annotation!)
        }
        self.view.endEditing(true)
        self.calculate.isEnabled = true
    }
    
    /**
     Action for when the Time Box Is Pressed
     
     - Parameter sender:   Access to the UIButton "Calculate Route"
     
     */
    @IBAction func timeBoxButton(_ sender: UIButton) {
        
        //Hour in 24-Hour Time
        //Minutes as Normal
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let timeOfDay = calendar.component(.era, from: date as Date)
        
        let y : String
        
        //Deciding AM or PM
        if (timeOfDay == 1) {
            y = "PM"
        } else {
            y = "AM"
        }
        
        //If Time Data is in Hours ( Long Distnace )
        if (self.hours != nil) {
            let newHour = hour + Int(self.hours)!
            let newMinutes = minutes + Int(self.minutes)!
            
            if (newMinutes > 60) {
                
                let leftOver = newMinutes % 60
                
                var x : String = "\(leftOver)"
                
                if (leftOver == 1) {
                    x = "\(leftOver)"
                    x = "01"
                }
                if (leftOver == 2) {
                    x = "\(newMinutes)"
                    x = "02"
                }
                if (leftOver == 3) {
                    x = "\(leftOver)"
                    x = "03"
                }
                if (leftOver == 4) {
                    x = "\(leftOver)"
                    x = "04"
                }
                if (leftOver == 5) {
                    x = "\(leftOver)"
                    x = "05"
                }
                if (leftOver == 6) {
                    x = "\(leftOver)"
                    x = "06"
                }
                if (leftOver == 7) {
                    x = "\(leftOver)"
                    x = "07"
                }
                if (leftOver == 8) {
                    x = "\(leftOver)"
                    x = "08"
                }
                if (leftOver == 9) {
                    x = "\(leftOver)"
                    x = "09"
                }
                if (leftOver == 60) {
                    //hour += 1
                    x = "00"
                }
                
                //Chagne Time Box
                if (newHour > 12) {
                    self.timeLabel.text = ("\((newHour + 1) - 12)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                } else {
                    self.timeLabel.text = ("\(newHour + 1)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                }
                
            } else {
                
                var x : String = "\(newMinutes)"
                
                if (newMinutes == 1) {
                    x = "\(newMinutes)"
                    x = "01"
                }
                if (newMinutes == 2) {
                    x = "\(newMinutes)"
                    x = "02"
                }
                if (newMinutes == 3) {
                    x = "\(newMinutes)"
                    x = "03"
                }
                if (newMinutes == 4) {
                    x = "\(newMinutes)"
                    x = "04"
                }
                if (newMinutes == 5) {
                    x = "\(newMinutes)"
                    x = "05"
                }
                if (newMinutes == 6) {
                    x = "\(newMinutes)"
                    x = "06"
                }
                if (newMinutes == 7) {
                    x = "\(newMinutes)"
                    x = "07"
                }
                if (newMinutes == 8) {
                    x = "\(newMinutes)"
                    x = "08"
                }
                if (newMinutes == 9) {
                    x = "\(newMinutes)"
                    x = "09"
                }
                if (newMinutes == 60) {
                    hour += 1
                    x = "00"
                }

                //Chagne Time Box
                if (newHour > 12) {
                    self.timeLabel.text = ("\(newHour - 12)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                } else {
                    self.timeLabel.text = ("\(newHour)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                }
            }
            
            
        //If Time Data is in Minutes ( Short Distnace )
        } else {
            let newMinutes = minutes + Int(self.minutes)!
            
            //If newMinutes Is Greater Than 60
            if (newMinutes > 60) {
                let leftOver = newMinutes % 60
                let hoursPlus = newMinutes / 60
                
                var x : String = "\(leftOver)"
                
                if (leftOver == 1) {
                    x = "\(leftOver)"
                    x = "01"
                }
                if (leftOver == 2) {
                    x = "\(newMinutes)"
                    x = "02"
                }
                if (leftOver == 3) {
                    x = "\(leftOver)"
                    x = "03"
                }
                if (leftOver == 4) {
                    x = "\(leftOver)"
                    x = "04"
                }
                if (leftOver == 5) {
                    x = "\(leftOver)"
                    x = "05"
                }
                if (leftOver == 6) {
                    x = "\(leftOver)"
                    x = "06"
                }
                if (leftOver == 7) {
                    x = "\(leftOver)"
                    x = "07"
                }
                if (leftOver == 8) {
                    x = "\(leftOver)"
                    x = "08"
                }
                if (leftOver == 9) {
                    x = "\(leftOver)"
                    x = "09"
                }
                if (leftOver == 60) {
                    hour += 1
                    x = "00"
                }
                
                //Chagne Time Box
                if (hour > 12) {
                    self.timeLabel.text = ("\((hour + hoursPlus) - 12)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                } else {
                    self.timeLabel.text = ("\(hour + hoursPlus)" + ":" + "\(x)" + " " +   "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                }
            }
                
            //If newMinutes Are Less Than 60
            else {
                
                var x : String = "\(newMinutes)"

                if (newMinutes == 1) {
                    x = "\(newMinutes)"
                    x = "01"
                }
                if (newMinutes == 2) {
                    x = "\(newMinutes)"
                    x = "02"
                }
                if (newMinutes == 3) {
                    x = "\(newMinutes)"
                    x = "03"
                }
                if (newMinutes == 4) {
                    x = "\(newMinutes)"
                    x = "04"
                }
                if (newMinutes == 5) {
                    x = "\(newMinutes)"
                    x = "05"
                }
                if (newMinutes == 6) {
                    x = "\(newMinutes)"
                    x = "06"
                }
                if (newMinutes == 7) {
                    x = "\(newMinutes)"
                    x = "07"
                }
                if (newMinutes == 8) {
                    x = "\(newMinutes)"
                    x = "08"
                }
                if (newMinutes == 9) {
                    x = "\(newMinutes)"
                    x = "09"
                }
                if (newMinutes == 60) {
                    hour += 1
                    x = "00"
                }
                
                //Chagne Time Box
                if (hour > 12) {
                    self.timeLabel.text = ("\(hour - 12)" + ":" + "\(x)" + " " +  "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                } else {
                    self.timeLabel.text = ("\(hour)" + ":" + "\(x)" + " " + "\(y)")
                    self.timeSubLabel.text = "Arrival Time"
                }
            }
        }
    }
    
    /**
     Action for when the Calculate Route Button is Pushed
     
     - Parameter sender:   Access to the UIButton "Calculate Route"

     */
    @IBAction func calculateRoute(_ sender: Any) {
    
        //Set Map Region to User Location
        myMap.setRegion(MKCoordinateRegionMake(myLocation, MKCoordinateSpanMake(0.08,0.08)), animated: true)
       
    
        //Call Directions from User Location to Uesr Inputed Location
        let directionsRequest = MKDirectionsRequest()
        let myLocationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(myLocation.latitude, myLocation.longitude), addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(pointAnnotation.coordinate.latitude, pointAnnotation.coordinate.longitude), addressDictionary: nil)
        directionsRequest.source = MKMapItem(placemark: myLocationPlaceMark)
        directionsRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.transportType = MKDirectionsTransportType.walking
        let directions = MKDirections(request: directionsRequest)
        
        //Caluculate Information About Directions
        directions.calculate { response, error in
            if let route = response?.routes.first {
                
                //Calculates Distance in Miles to Two Decimals
                let distance = route.distance
                let meterToMilesConvertion = 1609.344
                let distanceMiles = distance / meterToMilesConvertion
                let distanceMilesTwoDec = Double(round(100 * distanceMiles) / 100)

                //Calculates Time in Minutes with Two Decimals
                let speedMilesPerMinute = self.sliderValue / 60
                let time = distanceMiles / Double(speedMilesPerMinute)
                let timeRoundedTwoDecimals = Double(round(100 * time) / 100)
                let timeString = (String)(timeRoundedTwoDecimals)
                let timeString1 = (String)(timeRoundedTwoDecimals)

                
                //Calculating Time In Hours and Minutes
                if (timeRoundedTwoDecimals > 60) {
                    let timeInHours = timeRoundedTwoDecimals / 60
                    let timeInHoursInt:Int = Int(timeInHours)
                
                    let period1: Character = "."
                    let index1 = timeString.characters.index(of: period1)
                    let remainder1 = timeString.substring(from: index1!)
                    let myDouble1 = Double(remainder1)
                    let minutes = myDouble1! * 60
                    let minutes1Int:Int = Int(minutes)
                    
                    DispatchQueue.main.async {

                        self.timeLabel.text = ("\(timeInHoursInt)" + " Hour(s)")
                        self.timeSubLabel.text = ("\(minutes1Int)" + " Minutes")
                        self.hours = ("\(timeInHoursInt)")
                        self.minutes = ("\(minutes1Int)")
                        self.distanceLabel.text = ("\(distanceMilesTwoDec)" + " Miles")
                        self.distanceSubLevel.text = "Distance"
                        self.timeBoxButton.setImage(#imageLiteral(resourceName: "ace"), for: .normal)
                        self.distanceBox.image = UIImage( named : "ace" )
                    }
                } else {
                //Calculates Time in Minutes and Seconds
                    let period2: Character = "."
                    let index2 = timeString1.characters.index(of: period2)
                    let remainder2 = timeString1.substring(from: index2!)
                    let myDouble2 = Double(remainder2)
                    let seconds = myDouble2! * 60
                    let secondsInt:Int = Int(seconds)
                    let minutes2Int:Int = Int(timeRoundedTwoDecimals)

                    //Takes Care of Random Rounding Problem
                    DispatchQueue.main.async {

                        if ( (secondsInt == 1) || (secondsInt == 2) || (secondsInt == 3) || (secondsInt == 4) || (secondsInt == 5) || (secondsInt == 6) ) {
                            self.timeLabel.text = ("\(minutes2Int)" + ":" + "\(secondsInt)" + "0 Minutes")
                            self.minutes = ("\(minutes2Int)")
                            self.seconds = ("\(secondsInt)")
                        } else if ( (secondsInt == 7) || (secondsInt == 8) || (secondsInt == 9)) {
                            self.timeLabel.text = ("\(minutes2Int)" + ":" + "00 Minutes")
                            self.minutes = ("\(minutes2Int)")
                            self.seconds = ("00")
                        } else {
                            self.timeLabel.text = ("\(minutes2Int)" + ":" + "\(secondsInt)" + " Minutes")
                            self.minutes = ("\(minutes2Int)")
                            self.seconds = ("\(secondsInt)")
                        }
                    
                        self.distanceLabel.text = ("\(distanceMilesTwoDec)" + " Miles")
                        self.timeSubLabel.text = "Push For Arrival Time"
                        self.distanceSubLevel.text = "Distance"
                        self.timeBoxButton.setImage(#imageLiteral(resourceName: "ace"), for: .normal)
                        self.distanceBox.image = UIImage( named : "ace" )
                    }
                }
            } else {
                print("Error!")
            }
            if error == nil {
                self.myRoute = response!.routes[0] as MKRoute
                self.myMap.add(self.myRoute.polyline)
            }
        }
    }
}

