import UIKit
import MapKit
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var myMap: MKMapView!
    var myRoute : MKRoute!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notifications 
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
    
    }
    
    @IBAction func calculateRoute(_ sender: Any) {
        //Set up Route
        let point1 = MKPointAnnotation()
        let point2 = MKPointAnnotation()
        
        point1.coordinate = CLLocationCoordinate2DMake(40.4267, -86.9267)
        point1.title = "Hillendbrand Residence Hall"
        point1.subtitle = "Residence"
        myMap.addAnnotation(point1)
        
        point2.coordinate = CLLocationCoordinate2DMake(40.4277, -86.9170)
        point2.title = "Lawson Computer Science"
        point2.subtitle = "Education"
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
        
        //Notifications
        let content = UNMutableNotificationContent()
        content.title = "It's been a while!"
        content.subtitle = "Wana go for a bike ride?"
        content.body = "Switch over to Bike Travel to get the most accurate bike travel time and current speed while on the bike ride!"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Come Back!", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
    
    //Close Keyboard when return hit
    @IBAction func textFieldShouldReturn(_ sender: UITextField) {
        self.view.endEditing(true)
    }
}

