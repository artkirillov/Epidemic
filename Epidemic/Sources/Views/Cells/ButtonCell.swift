//
//  ButtonCell.swift
//  Coins
//
//  Created by Artem Kirillov on 26/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate: class {
    func buttonCellDidTouched(cell: ButtonCell)
}

final class ButtonCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: ButtonCell.self)
    
    weak var delegate: ButtonCellDelegate?
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Colors.backgroundColor
        
        button.layer.cornerRadius = button.bounds.height / 2
        button.backgroundColor = Colors.blueColor
        button.setTitleColor(Colors.minorTextColor, for: .disabled)
        button.setTitleColor(Colors.majorTextColor, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitle
        
        selectionStyle = .none
    }
    
    func configure(title: String, isEnabled: Bool, delegate: ButtonCellDelegate?) {
        button.setTitle(title, for: .normal)
        button.isEnabled = isEnabled
        self.delegate = delegate
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonCellDidTouched(cell: self)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var button: UIButton!
    
}
