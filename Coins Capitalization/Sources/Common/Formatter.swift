//
//  Formatter.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 12.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit
import Foundation

final class Formatter {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func format(_ number: Double) -> String? {
        return numberFormatter.string(from: abs(number) as NSNumber)
    }
    
    static func formatAmount(label: UILabel, value: Double, symbol: String) {
        numberFormatter.maximumFractionDigits = 10
        if let amount = Formatter.format(value) { label.text = "\(amount) \(symbol)" }
        numberFormatter.maximumFractionDigits = 2
    }
    
    static func formatCost(label: UILabel, value: Double) {
        if let cost = Formatter.format(value) { label.text = "$\(cost)" }
    }
    
    static func formatProfit(label: UILabel, firstValue: Double?, lastValue: Double?) {
        guard let firstValue = firstValue, let lastValue = lastValue, firstValue != 0 || lastValue != 0 else {
            label.text = ""
            return
        }
        
        let absoluteProfit = lastValue - firstValue
        let relativeProfit = absoluteProfit / firstValue * 100
        
        guard let profitText = Formatter.format(absoluteProfit), let percentText = Formatter.format(relativeProfit) else {
            label.text = ""
            return
        }
        
        if absoluteProfit > 0 {
            label.text = "↑ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.positiveGrow
        } else if absoluteProfit < 0 {
            label.text = "↓ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.negativeGrow
        }
    }
}
