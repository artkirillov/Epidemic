//
//  SingleInfoCell.swift
//  Coins
//
//  Created by Artem Kirillov on 24/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class SingleInfoCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: SingleInfoCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Colors.backgroundColor
        separator.backgroundColor = Colors.cellBackgroundColor
        
        titleLabel.textColor = Colors.minorTextColor
        titleLabel.font = Fonts.subtitle
        
        valueLabel.textColor = Colors.majorTextColor
        valueLabel.font = Fonts.subtitle
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
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var separator: UIView!
    
}
