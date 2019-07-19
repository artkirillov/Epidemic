//
//  TextFieldCell.swift
//  Coins
//
//  Created by Artem Kirillov on 09/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate: class {
    func textFieldCell(type: TextFiledType, didChangeText text: String?)
    func textFieldCellDoneButtonTapped(cell: TextFieldCell)
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
        textField.keyboardAppearance = .dark
        
        let buttonView = ButtonInputAccessoryView(title: NSLocalizedString("Done", comment: ""))
        buttonView.delegate = self
        textField.inputAccessoryView = buttonView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        textField.text = nil
    }
    
    func configure(type: TextFiledType, placeholder: String, keyboardType: UIKeyboardType = .decimalPad, delegate: TextFieldCellDelegate?)
    {
        self.type = type
        titleLabel.text = type.title.uppercased()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: Fonts.buttonTitle,
                .foregroundColor: Colors.majorTextColor]
        )
        textField.text = type.text
        textField.keyboardType = keyboardType
        
        self.delegate = delegate
    }
    
    func beginEdit() {
        textField.becomeFirstResponder()
    }
    
    @objc func buttonTapped() {
        
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textField: UITextField!
    
    private var type: TextFiledType = .price(nil, nil)
    
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
        delegate?.textFieldCell(type: type, didChangeText: textField.text)
    }
    
}

// MARK: - ButtonInputAccessoryViewDelegate

extension TextFieldCell: ButtonInputAccessoryViewDelegate {
    
    func buttonInputAccessoryViewDidTap(view: ButtonInputAccessoryView) {
        delegate?.textFieldCellDoneButtonTapped(cell: self)
    }
    
}
