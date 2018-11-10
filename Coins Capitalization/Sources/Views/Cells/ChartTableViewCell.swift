//
//  ChartTableViewCell.swift
//  Coins
//
//  Created by Artem Kirillov on 08.10.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol ChartTableViewCellDelegate {
    func chartTableViewCell(cell: ChartTableViewCell, changedPeriodWithMinPrice: Double, maxPrice: Double)
}

class ChartTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: ChartTableViewCell.self)
    
    var delegate: ChartTableViewCellDelegate?
    
    // MARK: - Constructors
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(coin: Coin, delegate: ChartTableViewCellDelegate?) {
        self.coin = coin
        self.delegate = delegate
        requestData(for: .day)
    }
    
    @objc func changeChartType(_ sender: SegmentedControl) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        noDataBackground.isHidden = true
        noDataLabel.isHidden = true
        
        switch sender.selectedIndex {
        case 0: requestData(for: .day)
        case 1: requestData(for: .week)
        case 2: requestData(for: .month)
        case 3: requestData(for: .threeMonths)
        case 4: requestData(for: .halfYear)
        case 5: requestData(for: .year)
        case 6: requestData(for: .all)
        default: break
        }
    }
    
    // MARK: - Private Properties
    
    private var coin: Coin?
    
    private let animation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = kCATransitionFade
        return animation
    }()
    
    private let chartView = ChartView()
    private let noDataBackground = UIView()
    private let noDataLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private let segmentedControl = SegmentedControl()
    private let separator = UIView()
    
}

private extension ChartTableViewCell {
    
    // MARK: - Private Methods
    
    func setupViews() {
        [chartView, noDataBackground, activityIndicator, segmentedControl, separator].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        backgroundColor = Colors.backgroundColor
        separator.backgroundColor = Colors.cellBackgroundColor
        
        noDataBackground.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noDataBackground.backgroundColor = Colors.cellBackgroundColor
        noDataBackground.layer.cornerRadius = 14.0
        noDataBackground.isHidden = true
        
        noDataLabel.textColor = Colors.minorTextColor
        noDataLabel.font = Fonts.subtitle
        noDataLabel.textAlignment = .center
        noDataLabel.text = NSLocalizedString("No data available", comment: "")
        noDataLabel.isHidden = true
        
        segmentedControl.selectedIndex = 0
        segmentedControl.thumbColor = Colors.blueColor
        segmentedControl.addTarget(self, action: #selector(changeChartType), for: .valueChanged)
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func setupConstraints() {
        
        chartView.heightAnchor.constraint(equalToConstant: 250.0).isActive = true
        chartView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        chartView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20.0).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        noDataBackground.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20.0).isActive = true
        noDataBackground.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        noDataLabel.topAnchor.constraint(equalTo: noDataBackground.topAnchor, constant: 7.0).isActive = true
        noDataLabel.bottomAnchor.constraint(equalTo: noDataBackground.bottomAnchor, constant: -7.0).isActive = true
        noDataLabel.leadingAnchor.constraint(equalTo: noDataBackground.leadingAnchor, constant: 20.0).isActive = true
        noDataLabel.trailingAnchor.constraint(equalTo: noDataBackground.trailingAnchor, constant: -20.0).isActive = true
        
        segmentedControl.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20.0).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0).isActive = true
        
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10.0).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}

// MARK: - Network Requests

private extension ChartTableViewCell {
    
    func requestData(for type: API.EndPoint.ChartType) {
        guard let symbol = coin?.short else { return }
        
        API.requestChartData(type: type, for: symbol,
                             success: { [weak self] chartData in
                                guard let slf = self else { return }
                                slf.chartView.layer.add(slf.animation, forKey: kCATransition)
                                slf.chartView.data = chartData.price.map { $0 }
                                slf.activityIndicator.stopAnimating()
                                slf.activityIndicator.isHidden = true
                                
                                let prices = chartData.price
                                slf.delegate?.chartTableViewCell(
                                    cell: slf,
                                    changedPeriodWithMinPrice: prices[0][1],
                                    maxPrice: prices[prices.count - 2][1])
            },
                             failure: { [weak self] error in
                                guard let slf = self else { return }
                                slf.activityIndicator.stopAnimating()
                                slf.activityIndicator.isHidden = true
                                slf.noDataBackground.isHidden = false
                                slf.noDataLabel.isHidden = false
        })
    }
    
}
