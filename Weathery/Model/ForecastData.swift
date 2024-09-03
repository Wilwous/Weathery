//
//  ForecastData.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import Foundation

struct ForecastData: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastList]
    let city: City
}

struct ForecastList: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let sys: SysForecast
    let dt_txt: String
}

struct SysForecast: Codable {
    let pod: String
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}
