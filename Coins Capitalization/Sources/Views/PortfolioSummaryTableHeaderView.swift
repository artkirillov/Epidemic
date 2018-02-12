//
//  PortfolioSummaryTableHeaderView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class PortfolioSummaryTableHeaderView: UIView {
    
    // MARK: - Public Methods
    
    func configure(totalSum: Int, profit: Double) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        if let text = numberFormatter.string(from: totalSum as NSNumber) {
            totalSumLabel.text = "Market Capitalization: $\(text)"
        } else {
            totalSumLabel.text = nil
        }
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        if let text = numberFormatter.string(from: profit as NSNumber) {
            profitLabel.text = "Bitcoin Dominance: \(text)%"
        } else {
            profitLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var totalSumLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

