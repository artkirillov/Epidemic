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
    
    func configure(total: Double, profit: Double) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        if let text = numberFormatter.string(from: total as NSNumber) {
            totalLabel.text = "$ \(text)"
        } else {
            totalLabel.text = nil
        }
        
        if let text = numberFormatter.string(from: (profit > 1 ? abs(profit - 1) : abs(profit)) as NSNumber) {
            profitLabel.text = "\(profit > 1 ? "↑" : "↓") \(text)%"
            profitLabel.textColor = profit > 1 ? Colors.positiveGrow : Colors.negativeGrow
        } else {
            profitLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

