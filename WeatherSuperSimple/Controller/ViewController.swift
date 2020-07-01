//
//  ViewController.swift
//  WeatherSuperSimple
//
//  Created by Marlhex on 2020-06-26.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView
import Network

class ViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var cityLael: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
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
    
    func searchUserLocation(_ location: String) {
        
        let weatherEndPoint = WeatherAPI.Endpoints.getUserInfo(cityName: location).url
        
        //Here is the factored code to make the network request outside of the ViewController
        NetworkController.requestWeatherData(url: weatherEndPoint) { (data, error) in
            
            guard let data = data else { return }
            
            // N bytes (457 bytes dublin)
            //print(data)
            
            let decoder = JSONDecoder()
            
            do {
                
                // self here means we are referring the definition of WeatherJson we just created, not the instance of the struct.
                let weatherData = try decoder.decode(WeatherJson.self, from: data)
                
                // Json decoded or parsed: now you're able to see the json structure that you are decoding.
                // Dublin decoded or parsed into our model object WeatherJson
                //print(weatherData)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.cityLael.text = weatherData.name
                    self.descLbl.text = weatherData.weather[0].description
                    self.tempNumLbl.text = String(weatherData.main.temp)
                }
                
            }
            catch {
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.locationTextField.text = "That's not a city, try again!"
                }
                print("That's not a city!, " + error.localizedDescription)
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
            
            // Array from dataSource fetched with coreData
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
