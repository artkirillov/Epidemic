//
//  Market.swift
//  Coins
//
//  Created by Artem Kirillov on 11/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Market: Codable {
    
    var exchangeId: String
    var baseSymbol: String
    var baseId: String
    var quoteSymbol: String
    var quoteId: String
    var priceQuote: Double
    var priceUsd: Double
    
}
