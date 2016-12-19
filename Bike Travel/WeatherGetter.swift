//
//  WeatherGetter.swift
//  Bike Travel
//
//  Created by Kyle Brown on 12/18/16.
//  Copyright © 2016 Kyle Brown. All rights reserved.
//

import Foundation

class WeatherGetter {
    /*
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "2a0e4c51a24010f830e178e810f59517"
    
    func getWeather(city: String) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                do {
                    // Try to convert that data into a Swift dictionary
                    let weather = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]
                    
                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Let's print its contents to the debug console.
                    
                    print("Wind direction: \(weather["wind"]!["deg"]!!) degrees")
                    print("Wind speed: \(weather["wind"]!["speed"]!!)")
                

                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
         
                    
                    print("JSON error description: \(jsonError.description)")
                }
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
        
    }*/
    
    
}
