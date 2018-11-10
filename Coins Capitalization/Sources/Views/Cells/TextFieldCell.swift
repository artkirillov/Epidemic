//
//  TextFieldCell.swift
//  Coins
//
//  Created by Artem Kirillov on 09/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate: class {
    func textFieldCell(cell: TextFieldCell, didChangeText text: String?)
}

final class TextFieldCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: TextFieldCell.self)
    
    weak var delegate: TextFieldCellDelegate?
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = Colors.backgroundColor
        
        titleLabel.textColor = Colors.minorTextColor
        titleLabel.font = Fonts.description
        
        textField.textColor = Colors.majorTextColor
        textField.font = Fonts.title
        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.keyboardAppearance = .dark
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        textField.text = nil
    }
    
    func configure(title: String, placeholder: String, text: String?, delegate: TextFieldCellDelegate?) {
        titleLabel.text = title.uppercased()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: Fonts.buttonTitle,
                .foregroundColor: Colors.majorTextColor]
        )
        textField.text = text
        
        self.delegate = delegate
    }
    
    func beginEdit() {
        textField.becomeFirstResponder()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textField: UITextField!
    
}

// MARK: - UITextFieldDelegate

extension TextFieldCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //guard let textFieldText = textField.text else { return true }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldCell(cell: self, didChangeText: textField.text)
    }
    
}

