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
    
    enum Kind: String, Codable {
        case buy
        case sell
        case transfer
    }
    
    // MARK: - Public Properties
    
    var kind: Kind
    var exchange: Exchange?
    var baseSymbol: String
    var quoteSymbol: String
    var price: Double
    var priceUsd: Double
    var quantity: Double
    var fee: Double
    var date: Date
    
    // MARK: - Constructors
    
    init(kind: Kind = .buy,
        exchange: Exchange? = nil,
        baseSymbol: String = "",
        quoteSymbol: String = "",
        price: Double = 0.0,
        priceUsd: Double = 0.0,
        quantity: Double = 0.0,
        fee: Double = 0.0,
        date: Date = Date())
    {
        self.kind = kind
        self.exchange = exchange
        self.baseSymbol = baseSymbol
        self.quoteSymbol = baseSymbol
        self.price = price
        self.priceUsd = priceUsd
        self.quantity = quantity
        self.fee = fee
        self.date = date
    }
    
}

