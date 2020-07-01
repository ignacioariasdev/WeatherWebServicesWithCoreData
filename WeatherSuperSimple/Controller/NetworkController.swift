//
//  NetworkController.swift
//  WeatherSuperSimple
//
//  Created by Ignacio Arias on 2020-07-01.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import UIKit

class NetworkController {

    // This method exist because we need to remove network calls on the ViewController.
    // Now we are moving out the NetworkRequest calls outside of the ViewController
    
    // Marked as a class method because we don't need an instance of the NetworkController class in order to use it.
    class func requestWeatherData(url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                
                completionHandler(nil, error)
                return
            }
            
            //Adding the completionHandler that we have up there in this class method as a parameter
            completionHandler(data, nil)
       
        }
        task.resume()
        
    }

}
