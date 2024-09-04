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
    private var searchResults: [WeatherData] = []
    
    // MARK: - UI Components
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск города"
        
        customizeSearchBarAppearance(searchController.searchBar)
        
        return searchController
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(CityWeatherCell.self, forCellReuseIdentifier: "CityWeatherCell")
        
        return table
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchWeatherForCities()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let cancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitleColor(.black, for: .normal)
            cancelButton.titleLabel?.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchWeatherForCities() {
        let cities = ["Москва", "Тюмень", "Калуга", "Будва"]
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
    
    // MARK: - Setup View
    
    private func customizeSearchBarAppearance(_ searchBar: UISearchBar) {
        searchBar.backgroundImage = UIImage()
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        searchBar.searchTextField.autocorrectionType = .no
        searchBar.layer.shadowColor = UIColor.clear.cgColor
        searchBar.searchTextField.layer.masksToBounds = true
    }
    
    private func setupUI() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CitiesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CityWeatherCell",
            for: indexPath
        ) as? CityWeatherCell else {
            return UITableViewCell()
        }
        
        let data = searchController.isActive ? searchResults[indexPath.row] : weatherData[indexPath.row]
        cell.configure(with: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = searchController.isActive ? searchResults[indexPath.row] : weatherData[indexPath.row]
        
        if searchController.isActive {
            searchController.isActive = false
            weatherData.append(selectedCity)
            tableView.reloadData()
        } else {
            let detailVC = WeatherDetailViewController()
            detailVC.cityName = selectedCity.name
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in
            
            if self.searchController.isActive {
                self.searchResults.remove(at: indexPath.row)
            } else {
                self.weatherData.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .white
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.setTitleColor(.black, for: .normal)
        deleteButton.titleLabel?.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        deleteButton.sizeToFit()
        UIGraphicsBeginImageContext(deleteButton.bounds.size)
        deleteButton.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let buttonImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        deleteAction.image = buttonImage
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate

extension CitiesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }
        
        viewModel.fetchWeather(for: searchText)
        
        viewModel.onWeatherDataUpdate = { [weak self] weatherData in
            guard let self = self else { return }
            self.searchResults = [weatherData]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.onError = { error in
            print("Error searching city: \(error)")
        }
    }
}
