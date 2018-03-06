//
//  AssetTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class AssetTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        nameLabel.text = ""
        amountLabel.text = ""
        totalCostLabel.text = ""
        profitLabel.text = ""
    }
    
    func configure(asset: Asset) {
        
        nameLabel.text = asset.name
        
        let totalAmount = asset.totalAmount
        setNumber(label: amountLabel, value: totalAmount, suffix: " \(asset.symbol)", maximumFractionDigits: 6)
        
        guard asset.currentPrice != nil else {
            totalCostLabel.text = "No info"
            profitLabel.text = "No info"
            totalCostLabel.textColor = .lightGray
            profitLabel.textColor = .lightGray
            return
        }
        
        let currentTotalCost = asset.currentTotalCost
        setNumber(label: totalCostLabel, value: currentTotalCost, prefix: "$")
        
        let totalCost = asset.totalCost
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
        let relativeProfit = absoluteProfit / cost * 100
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        let profitText = numberFormatter.string(from: abs(absoluteProfit) as NSNumber) ?? "---"
        let percentText = numberFormatter.string(from: abs(relativeProfit) as NSNumber) ?? "---"
        
        if absoluteProfit > 0 {
            label.text = "↑ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.positiveGrow
        } else if absoluteProfit < 0 {
            label.text = "↓ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.negativeGrow
        }
    }
    
    func setNumber(label: UILabel, value: Double, prefix: String? = nil, suffix: String? = nil, maximumFractionDigits: Int = 0) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        guard let text = numberFormatter.string(from: value as NSNumber) else {
            label.text = nil
            return
        }
        
        label.text = "\(prefix ?? "")\(text)\(suffix ?? "")"
    }
    
}


