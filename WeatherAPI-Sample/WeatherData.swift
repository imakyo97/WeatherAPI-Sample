//
//  WeatherData.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/22.
//

import Foundation
import Metal

struct WeatherData: Codable {
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
