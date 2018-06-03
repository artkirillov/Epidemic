//
//  TickerTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 24.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class TickerTableViewCell: UITableViewCell {
    
    struct Default {
        static let noInfo = "No info"
    }
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        nameLabel.text = ""
        symbolLabel.text = ""
        priceUSDLabel.text = ""
        priceBTCLabel.text = ""
        marketCapUSDLabel.text = ""
        availableSupplyLabel.text = ""
        totalSupplyLabel.text = ""
        percentChange1hLabel.text = Default.noInfo
        percentChange24hLabel.text = Default.noInfo
        percentChange7dLabel.text = Default.noInfo
        
        percentChange1hLabel.textColor = .lightGray
        percentChange24hLabel.textColor = .lightGray
        percentChange7dLabel.textColor = .lightGray
    }
    
    func configure(ticker: Ticker) {
        
        nameLabel.text = ticker.name
        symbolLabel.text = ticker.symbol
        
        setNumber(label: priceBTCLabel, value: ticker.priceBTC ?? "", suffix: " BTC", maximumFractionDigits: 10)
        setNumber(label: priceUSDLabel, value: ticker.priceUSD ?? "", prefix: "$")
        
        setNumber(label: marketCapUSDLabel, value: ticker.marketCapUSD ?? Default.noInfo, prefix: "$")
        setNumber(label: availableSupplyLabel, value: ticker.availableSupply ?? Default.noInfo, suffix: " \(ticker.symbol)")
        
        setPercent(label: percentChange1hLabel, value: ticker.percentChange1h ?? Default.noInfo)
        setPercent(label: percentChange24hLabel, value: ticker.percentChange24h ?? Default.noInfo)
        setPercent(label: percentChange7dLabel, value: ticker.percentChange7d ?? Default.noInfo)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var priceUSDLabel: UILabel!
    @IBOutlet private var percentChange1hLabel: UILabel!
    @IBOutlet private var percentChange24hLabel: UILabel!
    @IBOutlet private var percentChange7dLabel: UILabel!
    @IBOutlet private var priceBTCLabel: UILabel!
    @IBOutlet private var marketCapUSDLabel: UILabel!
    @IBOutlet private var availableSupplyLabel: UILabel!
    @IBOutlet private var totalSupplyLabel: UILabel!
    
}

fileprivate extension TickerTableViewCell {
    
    func setPercent(label: UILabel, value: String) {
        guard let val = Double(value) else {
            label.text = Default.noInfo
            return
        }
        
        if val > 0 {
            setNumber(label: label, value: value, prefix: "+", suffix: "%")
            label.textColor = Colors.positiveGrow
        } else if val < 0 {
            setNumber(label: label, value: value, suffix: "%")
            label.textColor = Colors.negativeGrow
        }
    }
    
    func setNumber(label: UILabel, value: String, prefix: String? = nil, suffix: String? = nil, maximumFractionDigits: Int = 5) {
        guard let val = Double(value) else {
            label.text = Default.noInfo
            return
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        let text = numberFormatter.string(from: val as NSNumber)
        
        label.text = "\(prefix ?? "")\(text ?? "")\(suffix ?? "")"
    }
    
}

