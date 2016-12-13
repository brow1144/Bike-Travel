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
    @IBOutlet weak var timeBox: UIImageView!
    @IBOutlet weak var distanceBox: UIImageView!
    @IBOutlet weak var speedLabel: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    
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
    var sliderValue : Float! = 9.8
    
    //View Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myMap.delegate = self
        
        slider.isEnabled = true
        
        //Make Time and Distance Box Invisible When Launched
        self.timeBox.image = nil
        self.distanceBox.image = nil
        
        //User Location Set - Up
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        //User Notifications Set - Up
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
    
    //User Location Method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Finds User Location and Show
        let location = locations[0]
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        myMap.setRegion(region, animated: true)
        self.myMap.showsUserLocation = true
        
        //Allow User To Move off User Location
        manager.stopUpdatingLocation()
    }
    
    //Map View Method
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //Draws and Changes Route Characteristics
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        myLineRenderer.strokeColor = UIColor.green
        myLineRenderer.lineWidth = 3
        return myLineRenderer
        
    }
    
    //User Hits Route After Typing
    @IBAction func textFieldShouldReturn(_ sender: UITextField) {
        
        //Remove All Previous Map Annotations
        if (pointAnnotation != nil) {
            myMap.removeAnnotation(pointAnnotation)
        }
        
        //Remove All Time and Distance Information
        self.timeBox.image = nil
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
    }
    
    //Recieve Memory Warning Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Slider Moved Method
    @IBAction func sliderMoved(_ sender: UISlider) {
        self.sliderValue = sender.value
        self.speedLabel.title = ("\(Int(sender.value))" + " mph")
    }
    
    
    //User Pressed Calculate Route Button
    @IBAction func calculateRoute(_ sender: Any) {

        //Set Map Region to User Location
        myMap.setRegion(MKCoordinateRegionMake(myLocation, MKCoordinateSpanMake(0.03,0.03)), animated: true)
        
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
                let timeString2 = (String)(timeRoundedTwoDecimals)

                
                //Calculating Time In Hours and Minutes
                let timeInHours = timeRoundedTwoDecimals / 60
                let timeInHoursInt:Int = Int(timeInHours)
                
                let period1: Character = "."
                let index1 = timeString.characters.index(of: period1)
                let remainder1 = timeString.substring(from: index1!)
                let myDouble1 = Double(remainder1)
                let minutes = myDouble1! * 60
                let minutes1Int:Int = Int(minutes)
                
                //Calculates Time in Minutes and Seconds
                let period2: Character = "."
                let index2 = timeString2.characters.index(of: period2)
                let remainder2 = timeString.substring(from: index2!)
                let myDouble2 = Double(remainder2)
                let seconds = myDouble2! * 60
                let secondsInt:Int = Int(seconds)
                let minutes2Int:Int = Int(timeRoundedTwoDecimals)
                
                //Shows Time and Distance Information
                    //If Time is Greater Than An Hour Set Up Time Different
                if (timeRoundedTwoDecimals > 60 ) {
                    self.timeLabel.text = ("\(timeInHoursInt)" + " Hour(s)")
                    self.timeSubLabel.text = ("\(minutes1Int)" + " Minutes")
                    self.distanceLabel.text = ("\(distanceMilesTwoDec)" + " Miles")
                    self.distanceSubLevel.text = "Distance"
                    self.timeBox.image = UIImage( named : "ace" )
                    self.distanceBox.image = UIImage( named : "ace" )
                }
                //If Time is Less Than an Hour Set Up Time By Normal
                else {
                    self.timeLabel.text = ("\(minutes2Int)" + ":" + "\(secondsInt)" + " Minutes")
                    self.distanceLabel.text = ("\(distanceMilesTwoDec)" + " Miles")
                    self.timeSubLabel.text = "Time"
                    self.distanceSubLevel.text = "Distance"
                    self.timeBox.image = UIImage( named : "ace" )
                    self.distanceBox.image = UIImage( named : "ace" )
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

