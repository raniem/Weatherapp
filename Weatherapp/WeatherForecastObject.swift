//
//  WeatherForecastObject.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 09/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import Foundation

struct WeatherForecastObject : Decodable {
    
    let list : [WeatherObject]
    
    enum CodingKeys : String, CodingKey {
        case list
    }
    
    init() {
        list = []
    }
}
