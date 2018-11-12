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
    
    // MARK: - Public Properties
    
    var kind: String
    var exchange: String
    var baseSymbol: String
    var quoteSymbol: String
    var price: Double
    var quantity: Double
    var date: Date
    var commision: Double?
    var notes: String?
    
    // MARK: - Constructors
    
    init(kind: String = "",
        exchange: String = "",
        baseSymbol: String = "",
        quoteSymbol: String = "",
        price: Double = 0.0,
        quantity: Double = 0.0,
        date: Date = Date(),
        commision: Double? = nil,
        notes: String? = nil)
    {
        self.kind = kind
        self.exchange = exchange
        self.baseSymbol = baseSymbol
        self.quoteSymbol = baseSymbol
        self.price = price
        self.quantity = quantity
        self.date = date
        self.commision = commision
        self.notes = notes
    }
    
}

