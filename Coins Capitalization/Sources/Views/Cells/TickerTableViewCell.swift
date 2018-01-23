//
//  TickerTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 24.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class TickerTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        nameLabel.text = ""
        symbolLabel.text = ""
        priceUSDLabel.text = ""
        priceBTCLabel.text = ""
        marketCapUSDLabel.text = ""
        availableSupplyLabel.text = ""
        totalSupplyLabel.text = ""
        percentChange1hLabel.text = "---"
        percentChange24hLabel.text = "---"
        percentChange7dLabel.text = "---"
    }
    
    func configure(ticker: Ticker) {
        
        nameLabel.text = ticker.name
        symbolLabel.text = ticker.symbol
        
        setNumber(label: priceBTCLabel, value: ticker.priceBTC, suffix: " BTC", maximumFractionDigits: 7)
        setNumber(label: priceUSDLabel, value: ticker.priceUSD, prefix: "$")
        
        setNumber(label: marketCapUSDLabel, value: ticker.marketCapUSD, prefix: "$")
        setNumber(label: availableSupplyLabel, value: ticker.availableSupply, suffix: " \(ticker.symbol)")
        setNumber(label: totalSupplyLabel, value: ticker.totalSupply, suffix: " \(ticker.symbol)")
        
        setPercent(label: percentChange1hLabel, value: ticker.percentChange1h)
        setPercent(label: percentChange24hLabel, value: ticker.percentChange24h)
        setPercent(label: percentChange7dLabel, value: ticker.percentChange7d)
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
            label.text = ""
            return
        }
        
        if val > 0 {
            setNumber(label: label, value: value, prefix: "+", suffix: "%")
            label.textColor = UIColor(red: 148/255, green: 184/255, blue: 108/255, alpha: 1.0)
        } else if val < 0 {
            setNumber(label: label, value: value, suffix: "%")
            label.textColor = UIColor(red: 210/255, green: 80/255, blue: 78/255, alpha: 1.0)
        }
    }
    
    func setNumber(label: UILabel, value: String, prefix: String? = nil, suffix: String? = nil, maximumFractionDigits: Int = 5) {
        guard let val = Double(value) else { return }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        let text = numberFormatter.string(from: val as NSNumber)
        
        label.text = "\(prefix ?? "")\(text ?? "")\(suffix ?? "")"
    }
    
}

