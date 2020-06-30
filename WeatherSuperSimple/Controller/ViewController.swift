//
//  ViewController.swift
//  WeatherSuperSimple
//
//  Created by Marlhex on 2020-06-26.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import NVActivityIndicatorView
import Network

//TODO: finish coreData implementation.

class ViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var cityLael: UILabel!
    
    @IBOutlet weak var tempNumLbl: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var dataController: DataController!
    
    //The weather object being presented
    var weathers: [Weather] = []
    
    var activityIndicator: NVActivityIndicatorView!
    
    
    
    @IBAction func search(_ sender: Any) {
        
        // Get the location that the user typed
        // Check that the location is not nil
        guard let userLocation = locationTextField.text else {
            return
        }
        
        // Show the loading indicator
        activityIndicator.startAnimating()
        
        // Search for the user favorite city location
        searchUserLocation(userLocation)
        
    }

    private func searchUserLocation(_ location: String) {
        
        let weatherEndPoint = WeatherAPI.Endpoints.getUserInfo(cityName: location).url
           
           Alamofire.request("\(weatherEndPoint)").responseJSON { response in
               
               self.activityIndicator.stopAnimating()
               
               if let responseStr = response.result.value {
                   let jsonResponse = JSON(responseStr)
                   let jsonWeather = jsonResponse["weather"].array![0]
                   
                   let jsonTemp = jsonResponse["main"]
                   
                   
                   self.cityLael.text = jsonResponse["name"].stringValue
                   
                   self.tempNumLbl.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
               }
           }
       }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loaderIndicator()
        coreDataLogic()
    }
    
    
    @available(iOS 12.0, *)
    func statusDidChange(status: NWPath.Status) {
        if status == .satisfied {
            // Internet connection is back on
            cityLael.text = ""
        } else {
            // No internet connection
            cityLael.text = "NO NETWORK"
            
        }
    }
    
    fileprivate func coreDataLogic() {
        //NSManagedContext, this is step 10.
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        
        
        //step 10.1
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            //Adding the fetch from coreData to the array of dataSource
            weathers = result
            //refresh UI by repopulating the data
            tableView.reloadData()
            
        }
        
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func loaderIndicator() {
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width - indicatorSize) / 2, y: (view.frame.height - indicatorSize) / 2 , width: indicatorSize, height: indicatorSize)
        
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)

    }
    
    @IBAction func addToDataPersistance(_ sender: Any) {
        addingRow()
    }
    
    func addingRow() {
        let name = cityLael.text
        let num = tempNumLbl.text
        self.addWeather(name: name!, num: num!)
    }
    
    
    
    //Adds a new weather to the end of the `weathers`  array
    func addWeather(name: String, num: String) {
        
        //Create
        let weather = Weather(context: dataController.viewContext)
        
        weather.name = name
        weather.temp = num
        
        
        //Save to persistent store
        try? dataController.viewContext.save()
        
        //Append adds to the end, insert adds to the init
        weathers.insert(weather, at: 0)
        
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        
    }
    
    
    
    // MARK: - Helpers
    var numberOfWeathers: Int { return weathers.count }
    
    func weather(at indexPath: IndexPath) -> Weather {
        return weathers[indexPath.row]
    }
}

// MARK: - DataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfWeathers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aWeather = weather(at: indexPath)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        
        cell.detailTextLabel?.text = aWeather.name
        
        cell.textLabel?.text = aWeather.temp
        
        return cell
    }
    
    
}
