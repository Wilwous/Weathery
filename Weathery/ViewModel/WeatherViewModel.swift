//
//  WeatherViewModel.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import Foundation

final class WeatherViewModel {
    
    // MARK: - Сlosure
    
    var onWeatherDataUpdate: ((WeatherData) -> Void)?
    var onForecastDataUpdate: ((ForecastData) -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Private Properties
    
    private let weatherService = WeatherService()
    
    // MARK: - Public Methods
    
    func fetchWeather(for city: String) {
        weatherService.fetchCurrentWeather(for: city) { [weak self] result in
            switch result {
            case .success(let weatherData):
                self?.onWeatherDataUpdate?(weatherData)
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func fetchForecast(for city: String) {
        weatherService.fetchForecast(for: city) { [weak self] result in
            switch result {
            case .success(let forecastData):
                self?.onForecastDataUpdate?(forecastData)
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func iconName(for weatherCondition: String, isDaytime: Bool) -> String {
        switch weatherCondition.lowercased() {
        case "clear":
            return isDaytime ? "weather_clear_day_icon" : "weather_clear_night_icon"
        case "clouds":
            return "weather_cloudy_icon"
        case "rain":
            return "weather_rain_icon"
        case "storm", "thunderstorm":
            return "weather_storm_icon"
        case "snow":
            return "weather_snow_icon"
        case "fog", "mist", "haze":
            return "weather_fog_icon"
        default:
            return "weather_cloudy_icon"
        }
    }
}
