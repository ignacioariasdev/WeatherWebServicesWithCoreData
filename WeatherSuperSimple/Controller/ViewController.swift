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

//TODO: finish coreData implementation.

class ViewController: UIViewController {


	@IBOutlet weak var cityLael: UILabel!

	@IBOutlet weak var descripitonLbl: UILabel!
	
	@IBOutlet weak var tempNumLbl: UILabel!

	@IBOutlet var tableView: UITableView!

	var dataController: DataController!

	//The weather object being presented
	var weathers: [Weather] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let weatherEndPoint = WeatherAPI.EndPoint.base.url

		Alamofire.request("\(weatherEndPoint)").responseJSON { response in

			if let responseStr = response.result.value {
				let jsonResponse = JSON(responseStr)
				let jsonWeather = jsonResponse["weather"].array![0]
				
				let jsonTemp = jsonResponse["main"]


				self.descripitonLbl.text = "Lat 0 & Lon 0"
				

				self.cityLael.text = jsonResponse["name"].stringValue

				self.tempNumLbl.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
			}
		}

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


		//txtField.text = "sea creativo"
	}


	@IBAction func addToTableView(_ sender: Any) {
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
		//supplier.creationDate = Date()


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
