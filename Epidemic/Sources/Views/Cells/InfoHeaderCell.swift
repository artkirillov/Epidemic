//
//  InfoHeaderCell.swift
//  Coins
//
//  Created by Artem Kirillov on 23/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class InfoHeaderCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: InfoHeaderCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Colors.backgroundColor
        separator.backgroundColor = Colors.cellBackgroundColor
        
        headerLabel.textColor = Colors.majorTextColor
        headerLabel.font = Fonts.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headerLabel.text = nil
    }
    
    func configure(text: String) {
        headerLabel.text = text
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var separator: UIView!
    
}
