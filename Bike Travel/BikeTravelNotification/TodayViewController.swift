//
//  TodayViewController.swift
//  BikeTravelNotification
//
//  Created by Kyle Brown on 1/4/17.
//  Copyright © 2017 Kyle Brown. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var speedText: UILabel!

    //Weather Variables
    let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    let openWeatherMapAPIKey = "2a0e4c51a24010f830e178e810f59517"
    var speed : String!
    var direction : String!
    var weatherRequestURL : NSURL!
    
    override func viewDidLoad() {
        //self.speedText.text = nil
        super.viewDidLoad()
        //getWeather()
        // Do any additional setup after loading the view from its nib.
    }
    
    func getWeather() {
        
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
                        self.speedText.text = "\(speedTwo) mph"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
