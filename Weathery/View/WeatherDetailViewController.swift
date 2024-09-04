//
//  WeatherDetailViewController.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class WeatherDetailViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var cityName: String?
    
    // MARK: - Private Properties
    
    private let viewModel = WeatherViewModel()
    private var groupedForecastData: [DayWeather] = []
    
    // MARK: - UI Components
    
    private lazy var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 25)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 25)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var pressureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var windSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var windDirectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var visibilityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var weatherInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    private lazy var forecastTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.separatorStyle = .none
        table.register(
            DayForecastCell.self,
            forCellReuseIdentifier: "DayForecastCell"
        )
        
        return table
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        addElements()
        setupLayoutConstraint()
        setupBindings()
        fetchWeatherAndForecast()
    }
    
    // MARK: - Setup View
    
    private func setupNavigationBar() {
        let backButtonImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        let backButton = UIButton(type: .system)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.tintColor = .black
        backButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func addElements() {
        view.addSubview(weatherInfoContainerView)
        weatherInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        [weatherIconImageView,
         cityLabel,
         temperatureLabel,
         feelsLikeLabel,
         pressureLabel,
         humidityLabel,
         windSpeedLabel,
         windDirectionLabel,
         visibilityLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            weatherInfoContainerView.addSubview($0)
        }
        
        view.addSubview(forecastTableView)
        forecastTableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            weatherInfoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            weatherInfoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            weatherInfoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            weatherInfoContainerView.bottomAnchor.constraint(equalTo: visibilityLabel.bottomAnchor, constant: 15),
            
            weatherIconImageView.topAnchor.constraint(equalTo: weatherInfoContainerView.topAnchor, constant: 5),
            weatherIconImageView.leadingAnchor.constraint(equalTo: weatherInfoContainerView.leadingAnchor, constant: 35),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 120),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 120),
            
            cityLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor),
            cityLabel.centerXAnchor.constraint(equalTo: weatherIconImageView.centerXAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
            temperatureLabel.centerXAnchor.constraint(equalTo: weatherIconImageView.centerXAnchor),
            
            feelsLikeLabel.topAnchor.constraint(equalTo: weatherInfoContainerView.topAnchor, constant: 15),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            pressureLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 10),
            pressureLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            humidityLabel.topAnchor.constraint(equalTo: pressureLabel.bottomAnchor, constant: 10),
            humidityLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            windSpeedLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 10),
            windSpeedLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            windDirectionLabel.topAnchor.constraint(equalTo: windSpeedLabel.bottomAnchor, constant: 10),
            windDirectionLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            visibilityLabel.topAnchor.constraint(equalTo: windDirectionLabel.bottomAnchor, constant: 10),
            visibilityLabel.trailingAnchor.constraint(equalTo: weatherInfoContainerView.trailingAnchor, constant: -15),
            
            forecastTableView.topAnchor.constraint(equalTo: weatherInfoContainerView.bottomAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        viewModel.onWeatherDataUpdate = { [weak self] weatherData in
            DispatchQueue.main.async {
                self?.cityLabel.text = weatherData.name
                self?.temperatureLabel.text = "\(Int(weatherData.main.temp))°C"
                
                let isDaytime = self?.viewModel.isCurrentWeatherDaytime(for: weatherData) ?? true
                self?.weatherIconImageView.image = UIImage(
                    named: self?.viewModel.iconName(
                        for: weatherData.weather.first?.main ?? "",
                        isDaytime: isDaytime
                    ) ?? "default_icon"
                )
                
                self?.feelsLikeLabel.text = "Ощущается как: \(Int(weatherData.main.feels_like))°C"
                self?.pressureLabel.text = "Давление: \(weatherData.main.pressure) hPa"
                self?.humidityLabel.text = "Влажность: \(weatherData.main.humidity)%"
                self?.windSpeedLabel.text = "Скорость ветра: \(weatherData.wind.speed) м/с"
                self?.windDirectionLabel.text = "Направление ветра: \(weatherData.wind.deg)°"
                self?.visibilityLabel.text = "Видимость: \(weatherData.visibility) м"
            }
        }
        
        viewModel.onForecastDataUpdate = { [weak self] forecastData in
            DispatchQueue.main.async {
                self?.groupedForecastData = self?.viewModel.groupForecastsByDay(forecastData.list) ?? []
                self?.forecastTableView.reloadData()
            }
        }
        
        viewModel.onError = { error in
            print("Error fetching forecast: \(error)")
        }
    }
    
    private func fetchWeatherAndForecast() {
        guard let cityName = cityName else { return }
        viewModel.fetchWeather(for: cityName)
        viewModel.fetchForecast(for: cityName)
    }
    
    // MARK: - Action
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension WeatherDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedForecastData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DayForecastCell",
            for: indexPath
        ) as? DayForecastCell else {
            return UITableViewCell()
        }
        cell.configure(with: groupedForecastData[indexPath.row])
        return cell
    }
}
