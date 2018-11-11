//
//  Transaction.swift
//  Coins
//
//  Created by Artem Kirillov on 28/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    
    // MARK: - Public Nested
    
    enum Kind: String {
        case buy
        case sell
        case transfer
    }
    
    var kind: String
    var exchange: String
    var baseSymbol: String
    var quoteSymbol: String
    var price: Double
    var quantity: Double
    var date: Date
    var commision: Double?
    var notes: String?
    
}

