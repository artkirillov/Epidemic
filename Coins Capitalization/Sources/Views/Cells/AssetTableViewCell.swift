//
//  AssetTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class AssetTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        nameLabel.text = ""
        amountLabel.text = ""
        totalCostLabel.text = ""
        profitLabel.text = ""
    }
    
    func configure(asset: Asset) {
        
        nameLabel.text = asset.name
        
        let totalAmount = asset.volume.reduce(0.0) { $0 + $1.amount }
        amountLabel.text = "\(totalAmount) \(asset.symbol)"
        
        let currentTotalCost = totalAmount * asset.currentPrice
        setNumber(label: totalCostLabel, value: "\(currentTotalCost)", prefix: "$")
        
        let totalCost = asset.volume.reduce(0.0) { $0 + ($1.amount * $1.price) }
        setProfit(label: profitLabel, cost: totalCost, currentCost: currentTotalCost)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var totalCostLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

fileprivate extension AssetTableViewCell {
    
    func setProfit(label: UILabel, cost: Double, currentCost: Double) {
        let absoluteProfit = currentCost - cost
        let relativeProfit = absoluteProfit / cost
        
        if absoluteProfit > 0 {
            label.text = "↑ \(absoluteProfit) (\(relativeProfit)%)"
            label.textColor = UIColor(red: 148/255, green: 184/255, blue: 108/255, alpha: 1.0)
        } else if absoluteProfit < 0 {
            label.text = "↓ \(absoluteProfit) (\(relativeProfit)%)"
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


