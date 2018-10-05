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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        totalLabel.font = Fonts.portfolioPrice
        totalLabel.textColor = Colors.majorTextColor
    }
    
    func configure(total: Double, value: Double, currentValue: Double) {
        Formatter.formatProfit(label: profitLabel, firstValue: value, lastValue: currentValue)
        
        if currentValue > 0, let text = Formatter.format(currentValue) {
            totalLabel.text = "$\(text)"
        } else {
            totalLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

