//
//  HourlyForecastCell.swift.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class HourlyForecastCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private let viewModel = WeatherViewModel()
    
    // MARK: - UI Components
    
    private lazy var iconImageView = UIImageView()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 17)
        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addElements()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with forecast: ForecastList) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: forecast.dt_txt) {
            timeLabel.text = hourFormatter.string(from: date)
        }
        
        temperatureLabel.text = "\(Int(forecast.main.temp))°C"
        
        if let weatherCondition = forecast.weather.first?.main {
            let isDaytime = viewModel.isForecastDaytime(forecast: forecast)
            let iconName = viewModel.iconName(for: weatherCondition, isDaytime: isDaytime)
            iconImageView.image = UIImage(named: iconName)
        }
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        contentView.addSubview(cellBackgroundView)
        cellBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        [timeLabel,
         iconImageView,
         temperatureLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cellBackgroundView.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            cellBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cellBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            cellBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            cellBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            timeLabel.topAnchor.constraint(equalTo: cellBackgroundView.topAnchor, constant: 10),
            timeLabel.centerXAnchor.constraint(equalTo: cellBackgroundView.centerXAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            iconImageView.centerXAnchor.constraint(equalTo: cellBackgroundView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            temperatureLabel.centerXAnchor.constraint(equalTo: cellBackgroundView.centerXAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: cellBackgroundView.bottomAnchor, constant: -10)
        ])
    }
}
