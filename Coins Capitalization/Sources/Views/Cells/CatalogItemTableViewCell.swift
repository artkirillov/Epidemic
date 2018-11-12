//
//  CatalogItemTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CatalogItemTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = ""
        nameLabel.text = ""
    }
    
    func configure(title: String, subtitle: String? = nil) {
        symbolLabel.text = title
        nameLabel.text = subtitle
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
}
