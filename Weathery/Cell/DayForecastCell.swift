//
//  DayForecastCell.swift
//  Weathery
//
//  Created by Антон Павлов on 03.09.2024.
//

import UIKit

final class DayForecastCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    private var hourlyForecasts: [ForecastList] = []
    
    // MARK: - UI Components
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "UbuntuCondensed-Regular", size: 21)
        
        return label
    }()
    
    private lazy var forecasСollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 115, height: 115)
        layout.minimumLineSpacing = 10
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.register(
            HourlyForecastCell.self,
            forCellWithReuseIdentifier: "HourlyForecastCell"
        )
        
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
    
    func configure(with dayWeather: DayWeather) {
        dayLabel.text = dayWeather.day
        hourlyForecasts = dayWeather.hourlyForecasts
        forecasСollectionView.reloadData()
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [dayLabel,
         forecasСollectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            forecasСollectionView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 10),
            forecasСollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            forecasСollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            forecasСollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            forecasСollectionView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension DayForecastCell: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return hourlyForecasts.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HourlyForecastCell",
            for: indexPath
        ) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: hourlyForecasts[indexPath.row])
        
        return cell
    }
}
