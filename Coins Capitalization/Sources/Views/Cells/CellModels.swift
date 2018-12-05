//
//  CellModels.swift
//  Coins
//
//  Created by Artem Kirillov on 05/12/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

enum TextFiledType {
    case price(String?, Double?)
    case quantity(Double?)
    case fee(String?, Double?)
    
    var title: String {
        switch self {
        case .price(let quote, _):
            if let quote = quote {
                return String(format: NSLocalizedString("Price in %@", comment: ""), quote)
            } else {
                return NSLocalizedString("Price", comment: "")
            }
        case .quantity: return NSLocalizedString("Quantity", comment: "")
        case .fee(let quote, _):
            if let quote = quote {
                return String(format: NSLocalizedString("Transaction price in %@", comment: ""), quote)
            } else {
                return NSLocalizedString("Transaction price", comment: "")
            }
        }
    }
    
    var text: String? {
        switch self {
        case .price(_, let value): return value.flatMap { Formatter.format($0, maximumFractionDigits: Formatter.maximumFractionDigits(for: $0)) }
        case .quantity(let value), .fee(_, let value): return value.flatMap { String($0) }
        }
    }
}
