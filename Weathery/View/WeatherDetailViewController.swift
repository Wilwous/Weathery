//
//  WeatherDetailViewController.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class WeatherDetailViewController: UIViewController {
    
    // MARK: - Publice Properties
    
    var cityName: String?
    
    // MARK: - Private Properties
    
    private let viewModel = WeatherViewModel()
    private var groupedForecastData: [DayWeather] = []
    
    // MARK: - UI Components
    
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
        fetchWeatherAndForecast()
    }
    
    // MARK: - Setup View
    
    private func setupNavigationBar() {
        let backButtonImage = UIImage(systemName: "chevron.left")?
            .withRenderingMode(.alwaysTemplate)
        
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
        [forecastTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            forecastTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func fetchWeatherAndForecast() {
        guard let cityName = cityName else { return }
        
        viewModel.fetchForecast(for: cityName)
        
        viewModel.onForecastDataUpdate = { [weak self] forecastData in
            self?.groupForecastsByDay(forecastData.list)
            DispatchQueue.main.async {
                self?.forecastTableView.reloadData()
            }
        }
        
        viewModel.onError = { error in
            print("Error fetching forecast: \(error)")
        }
    }
    
    private func groupForecastsByDay(_ forecasts: [ForecastList]) {
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
        
        self.groupedForecastData = orderedWeekdays.compactMap { day in
            if let forecasts = groupedForecasts[day] {
                return DayWeather(day: day, hourlyForecasts: forecasts)
            }
            return nil
        }
    }
    
    // MARK: - Action
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension WeatherDetailViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return groupedForecastData.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
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
