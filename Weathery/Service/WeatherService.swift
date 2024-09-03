//
//  WeatherService.swift
//  Weathery
//
//  Created by Антон Павлов on 02.09.2024.
//

import Foundation

final class WeatherService {
    
    private let session = URLSession.shared
    
    func fetchCurrentWeather(for city: String, lang: String = "ru", completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(RequestConstants.apiKey)&units=metric&lang=\(lang)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchForecast(for city: String, lang: String = "ru", completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(RequestConstants.apiKey)&units=metric&lang=\(lang)"
        guard let url = URL(string: urlString) else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let forecastData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(.success(forecastData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
