//
//  CitiesViewController.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class CitiesViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel = WeatherViewModel()
    private var weatherData: [WeatherData] = []
    private var cities = [
        "Москва",
        "Тюмень",
        "Калуга",
        "Черногория"
    ]
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.frame = view.bounds
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(
            CityWeatherCell.self,
            forCellReuseIdentifier: "CityWeatherCell"
        )
        
        return table
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchWeatherForCities()
        view.addSubview(tableView)
    }
    
    // MARK: - Private Methods
    
    private func fetchWeatherForCities() {
        for city in cities {
            viewModel.fetchWeather(for: city)
        }
        
        viewModel.onWeatherDataUpdate = { [weak self] weatherData in
            self?.weatherData.append(weatherData)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { error in
            print("Error fetching weather: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CitiesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return weatherData.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CityWeatherCell",
            for: indexPath
        ) as? CityWeatherCell else {
            return UITableViewCell()
        }
        let data = weatherData[indexPath.row]
        cell.configure(with: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = WeatherDetailViewController()
        detailVC.cityName = weatherData[indexPath.row].name
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
