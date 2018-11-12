//
//  OptionCell.swift
//  Coins
//
//  Created by Artem Kirillov on 27/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class OptionCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: OptionCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = Colors.backgroundColor
        
        titleLabel.textColor = Colors.minorTextColor
        titleLabel.font = Fonts.description
        
        valueLabel.textColor = Colors.majorTextColor
        valueLabel.font = Fonts.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
        disclosure.image = nil
    }
    
    func configure(title: String, value: String, disclosureImage: UIImage? = UIImage(imageLiteralResourceName: "disclosure")) {
        titleLabel.text = title.uppercased()
        valueLabel.text = value
        disclosure.image = disclosureImage
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var disclosure: UIImageView!
    
}
