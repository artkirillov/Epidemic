//
//  GlobalDataTableHeaderView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 28.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class GlobalDataTableHeaderView: UIView {

    // MARK: - Public Methods
    
    func configure(capitalization: Int) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        if let text = numberFormatter.string(from: capitalization as NSNumber) {
            capitalizationLabel.text = "Market Capitalization: $\(text)"
        } else {
            capitalizationLabel.text = nil
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var capitalizationLabel: UILabel!

}
