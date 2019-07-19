//
//  NSAttributedString.swift
//  Coins
//
//  Created by Artem Kirillov on 23.09.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    static func attributedTitle(string: String) -> NSAttributedString {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: Fonts.title,
                .foregroundColor: Colors.minorTextColor,
                .kern: 2.0]
        )
    }
    
    static func attributedTextFieldPlaceholder(string: String) -> NSAttributedString {
        return NSAttributedString(
            string: string,
            attributes: [
                .font: Fonts.messageText,
                .foregroundColor: Colors.minorTextColor]
        )
    }
    
}
