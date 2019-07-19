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
    
    func clear() {
        totalLabel.text = nil
        profitLabel.text = nil
    }
    
    func configure(value: Double?, currentValue: Double?) {
        clear()
        value.flatMap { Formatter.formatProfit(label: profitLabel, firstValue: $0, lastValue: currentValue) }
        currentValue.flatMap { Formatter.format($0, maximumFractionDigits: Formatter.maximumFractionDigits(for: $0))
            .flatMap { totalLabel.text = "$\($0)" } }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var totalLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

