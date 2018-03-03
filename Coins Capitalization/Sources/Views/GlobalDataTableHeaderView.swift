//
//  GlobalDataTableHeaderView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 28.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class GlobalDataTableHeaderView: UIView {

    // MARK: - Public Methods
    
    func configure(capitalization: Int, dominance: Double) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        if let text = numberFormatter.string(from: capitalization as NSNumber) {
            capitalizationLabel.text = "Market Capitalization: $\(text)"
        } else {
            capitalizationLabel.text = nil
        }
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        if let text = numberFormatter.string(from: dominance as NSNumber) {
            dominanceLabel.text = "Bitcoin Dominance: \(text)%"
        } else {
            dominanceLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var capitalizationLabel: UILabel!
    @IBOutlet private var dominanceLabel: UILabel!

}
