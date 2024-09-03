//
//  CityWeatherCell.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class CityWeatherCell: UITableViewCell {
    
    // MARK: - Private Properties
    
    private let viewModel = WeatherViewModel()
    
    // MARK: - UI Components
    
    private let iconImageView = UIImageView()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 21)
        
        return label
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 21)
        
        return label
    }()
    
    private lazy var cellBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addElements()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with data: WeatherData) {
        cityLabel.text = data.name
        temperatureLabel.text = "\(Int(data.main.temp))°C"
        
        if let weatherCondition = data.weather.first?.main {
            let iconName = viewModel.iconName(for: weatherCondition, isDaytime: isDaytime(data: data))
            iconImageView.image = UIImage(named: iconName)
        }
    }
    
    private func isDaytime(data: WeatherData) -> Bool {
        let currentTime = Date(timeIntervalSince1970: TimeInterval(data.dt))
        let sunrise = Date(timeIntervalSince1970: TimeInterval(data.sys.sunrise))
        let sunset = Date(timeIntervalSince1970: TimeInterval(data.sys.sunset))
        
        return currentTime >= sunrise && currentTime < sunset
    }
    
    // MARK: - Private Methods
    
    private func addElements() {
        contentView.addSubview(cellBackgroundView)
        cellBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        [cityLabel,
         iconImageView,
         temperatureLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cellBackgroundView.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            cellBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cellBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cellBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cellBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cellBackgroundView.heightAnchor.constraint(equalToConstant: 80),
            
            cityLabel.leadingAnchor.constraint(equalTo: cellBackgroundView.leadingAnchor, constant: 20),
            cityLabel.centerYAnchor.constraint(equalTo: cellBackgroundView.centerYAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: cellBackgroundView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: cellBackgroundView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: cellBackgroundView.trailingAnchor, constant: -20),
            temperatureLabel.centerYAnchor.constraint(equalTo: cellBackgroundView.centerYAnchor)
        ])
    }
}

