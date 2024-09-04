//
//  WeatherViewModel.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import Foundation

final class WeatherViewModel {
    
    // MARK: - Closures
    
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
    
    func groupForecastsByDay(_ forecasts: [ForecastList]) -> [DayWeather] {
        var groupedForecasts = [String: [ForecastList]]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "ru_RU")
        weekdayFormatter.dateFormat = "EEEE"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let sortedForecasts = forecasts.sorted {
            dateFormatter.date(from: $0.dt_txt)! < dateFormatter.date(from: $1.dt_txt)!
        }
        
        for forecast in sortedForecasts {
            if let forecastDate = dateFormatter.date(from: forecast.dt_txt) {
                if forecastDate >= today {
                    let day = weekdayFormatter.string(from: forecastDate).capitalized
                    groupedForecasts[day, default: []].append(forecast)
                }
            }
        }
        
        let todayWeekdayIndex = calendar.component(.weekday, from: today) - 1
        let orderedWeekdays = (0..<7).map { (todayWeekdayIndex + $0) % 7 }.map {
            weekdayFormatter.weekdaySymbols[$0].capitalized
        }
        
        return orderedWeekdays.compactMap { day in
            if let forecasts = groupedForecasts[day] {
                return DayWeather(day: day, hourlyForecasts: forecasts)
            }
            return nil
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
    
    func isCurrentWeatherDaytime(for data: WeatherData) -> Bool {
        let currentTime = Date(timeIntervalSince1970: TimeInterval(data.dt))
        let sunrise = Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise))
        let sunset = Date(timeIntervalSince1970: TimeInterval(data.sys.sunset))
        
        return currentTime >= sunrise && currentTime < sunset
    }
    
    func isForecastDaytime(forecast: ForecastList) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: forecast.dt_txt) {
            let hour = Calendar.current.component(.hour, from: date)
            return hour >= 6 && hour < 18
        }
        return true
    }
}
