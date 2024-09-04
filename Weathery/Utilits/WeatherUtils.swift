//
//  WeatherUtils.swift
//  Weathery
//
//  Created by Антон Павлов on 04.09.2024.
//

import Foundation

struct WeatherUtils {
    static func isCurrentWeatherDaytime(for data: WeatherData) -> Bool {
        let currentTime = Date(timeIntervalSince1970: TimeInterval(data.dt))
        let sunrise = Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise))
        let sunset = Date(timeIntervalSince1970: TimeInterval(data.sys.sunset))
        
        return currentTime >= sunrise && currentTime < sunset
    }
    
    static func isForecastDaytime(forecast: ForecastList) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: forecast.dt_txt) {
            let hour = Calendar.current.component(.hour, from: date)
            return hour >= 6 && hour < 18
        }
        return true
    }
}
