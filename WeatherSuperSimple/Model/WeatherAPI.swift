//
//  WeatherAPI.swift
//  WeatherSuperSimple
//
//  Created by Marlhex on 2020-06-26.
//  Copyright © 2020 Ignacio Arias. All rights reserved.
//

import Foundation

class WeatherAPI {

    enum Endpoints {
        static let base = "https://api.openweathermap.org/data/2.5/weather?q="

        case getUserInfo(cityName: String)
       

        var stringValue: String {
            switch self{

                case .getUserInfo(let cityName): return "\(Endpoints.base)\(cityName)&appid=dd9b28654c5a034286b8c15ee2a26830&units=metric"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }
 
    
}
