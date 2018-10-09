//
//  CurrentWeatherObject.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import Foundation

struct WeatherObject : Decodable {
    
    let weather : [WeatherInfo]
    let main : WeatherMain
    let dt_txt : String?
    
    enum CodingKeys : String, CodingKey {
        case weather
        case main
        case dt_txt
    }
}
