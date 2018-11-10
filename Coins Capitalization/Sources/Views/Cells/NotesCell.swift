//
//  NotesCell.swift
//  Coins
//
//  Created by Artem Kirillov on 10/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class NotesCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: NotesCell.self)
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = Colors.backgroundColor
        
        textView.textColor = Colors.majorTextColor
        textView.font = Fonts.title
        textView.keyboardAppearance = .dark
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
    }
    
    func configure(placeholder: String, text: String?) {
        textView.text = text
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var textView: UITextView!
    
}

// MARK: - UITextFieldDelegate

extension TextFieldCell: UITextViewDelegate {
    
}

