//
//  Coin.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 01.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Coin: Codable {
    
    var id: String
    var name: String
    var symbol: String
    var priceUSD: String?
    
    init(id: String, name: String, symbol: String, priceUSD: String?) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.priceUSD = priceUSD
    }
    
    init(ticker: Ticker) {
        self.init(id: ticker.id, name: ticker.name, symbol: ticker.symbol, priceUSD: ticker.priceUSD)
    }

}

