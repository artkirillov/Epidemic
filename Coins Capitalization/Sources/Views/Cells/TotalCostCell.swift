//
//  TotalCostCell.swift
//  Coins
//
//  Created by Artem Kirillov on 10/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class TotalCostCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: TotalCostCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = Colors.backgroundColor
        
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 14.0
        
        titleLabel.textColor = Colors.minorTextColor
        titleLabel.font = Fonts.subtitle
        
        valueLabel.textColor = Colors.majorTextColor
        valueLabel.font = Fonts.portfolioPrice
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title.uppercased()
        valueLabel.text = value
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var backView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    
}
