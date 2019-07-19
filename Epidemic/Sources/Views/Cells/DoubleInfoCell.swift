//
//  DoubleInfoCell.swift
//  Coins
//
//  Created by Artem Kirillov on 24/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class DoubleInfoCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: DoubleInfoCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Colors.backgroundColor
        separatorOne.backgroundColor = Colors.cellBackgroundColor
        separatorTwo.backgroundColor = Colors.cellBackgroundColor
        
        titleOneLabel.textColor = Colors.minorTextColor
        titleOneLabel.font = Fonts.subtitle
        
        titleTwoLabel.textColor = Colors.minorTextColor
        titleTwoLabel.font = Fonts.subtitle
        
        valueOneLabel.textColor = Colors.majorTextColor
        valueOneLabel.font = Fonts.subtitle
        
        valueTwoLabel.textColor = Colors.majorTextColor
        valueTwoLabel.font = Fonts.subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleOneLabel.text = nil
        valueOneLabel.text = nil
        
        titleTwoLabel.text = nil
        valueTwoLabel.text = nil
    }
    
    func configure(titleOne: String, valueOne: String, titleTwo: String, valueTwo: String) {
        titleOneLabel.text = titleOne.uppercased()
        valueOneLabel.text = valueOne
        
        titleTwoLabel.text = titleTwo.uppercased()
        valueTwoLabel.text = valueTwo
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleOneLabel: UILabel!
    @IBOutlet private var valueOneLabel: UILabel!
    @IBOutlet private var separatorOne: UIView!
    
    @IBOutlet private var titleTwoLabel: UILabel!
    @IBOutlet private var valueTwoLabel: UILabel!
    @IBOutlet private var separatorTwo: UIView!
    
}
