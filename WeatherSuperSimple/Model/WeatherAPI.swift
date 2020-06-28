//
//  WeatherAPI.swift
//  WeatherSuperSimple
//
//  Created by Marlhex on 2020-06-26.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import Foundation

class WeatherAPI {


enum EndPoint: String {

	case base = "https://api.openweathermap.org/data/2.5/weather?lat=0&lon=0&appid=dd9b28654c5a034286b8c15ee2a26830&units=metric"

	//Computed property
	var url: URL {
		return URL(string: self.rawValue)!
		}
	}

}
