//
//  TickerTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 24.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class TickerTableViewCell: UITableViewCell {
    
    struct Default {
        static let noInfo = NSLocalizedString("No info", comment: "")
    }
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = Colors.cellBackgroundColor
        containerView.layer.cornerRadius = 14.0
        
        symbolLabel.textColor = Colors.majorTextColor
        symbolLabel.font = Fonts.title
        
        nameLabel.textColor = Colors.minorTextColor
        nameLabel.font = Fonts.main
        
        priceLabel.textColor = Colors.majorTextColor
        priceLabel.font = Fonts.title
        
        percentLabel.textColor = Colors.minorTextColor
        percentLabel.font = Fonts.subtitle
        
        iconView.tintColor = Colors.lightBlueColor
        coinImageView.tintColor = Colors.lightBlueColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        symbolLabel.text = ""
        priceLabel.text = ""
        percentLabel.text = ""
    }
    
    func configure(coin: Coin) {
        
        selectionStyle = .none
        backgroundColor = .clear
        
        nameLabel.text = coin.long
        symbolLabel.text = coin.short
        
        if let image = UIImage(named: coin.long.lowercased())?.withRenderingMode(.alwaysTemplate) {
            iconView.image = image
            iconView.isHidden = false
            iconLabel.isHidden = true
        } else {
            iconLabel.text = coin.short
            iconLabel.isHidden = false
            iconView.isHidden = true
        }
        
        setNumber(label: priceLabel, value: coin.price, prefix: "$", maximumFractionDigits: Formatter.maximumFractionDigits(for: coin.price))
        setPercent(label: percentLabel, value: coin.cap24hrChange)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var percentLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var iconLabel: UILabel!
    @IBOutlet private var coinImageView: UIImageView!
}

fileprivate extension TickerTableViewCell {
    
    func setPercent(label: UILabel, value: Double) {
        if value > 0 {
            setNumber(label: label, value: value, prefix: "↑ ", suffix: "%")
            label.textColor = Colors.positiveGrow
        } else if value < 0 {
            setNumber(label: label, value: abs(value), prefix: "↓ ", suffix: "%")
            label.textColor = Colors.negativeGrow
        } else {
            label.text = "$0.00 (0.0%)"
            label.textColor = Colors.minorTextColor
        }
    }
    
    func setNumber(label: UILabel, value: Double, prefix: String? = nil, suffix: String? = nil,
                   maximumFractionDigits: Int = 2, minimumFractionDigits: Int = 2) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        numberFormatter.minimumFractionDigits = 2
        let text = numberFormatter.string(from: value as NSNumber)
        
        label.text = "\(prefix ?? "")\(text ?? "")\(suffix ?? "")"
    }
    
}
