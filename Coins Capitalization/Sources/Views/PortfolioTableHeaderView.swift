//
//  PortfolioTableHeaderView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class PortfolioTableHeaderView: UIView {
    
    // MARK: - Public Methods
    
    func configure(total: Double, value: Double, currentValue: Double) {
        let absoluteProfit = currentValue - value
        let relativeProfit = absoluteProfit / value * 100
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        let profitText = numberFormatter.string(from: abs(absoluteProfit) as NSNumber) ?? "---"
        let percentText = numberFormatter.string(from: abs(relativeProfit) as NSNumber) ?? "---"
        
        if absoluteProfit > 0 {
            profitLabel.text = "↑ $\(profitText) (\(percentText)%)"
            profitLabel.textColor = Colors.positiveGrow
        } else if absoluteProfit < 0 {
            profitLabel.text = "↓ $\(profitText) (\(percentText)%)"
            profitLabel.textColor = Colors.negativeGrow
        }
        
        if let text = numberFormatter.string(from: currentValue as NSNumber) {
            totalLabel.text = "$ \(text)"
        } else {
            totalLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

