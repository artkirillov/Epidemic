//
//  CoinDetails.swift
//  Coins
//
//  Created by Artem Kirillov on 25/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct CoinDetails: Codable {
    
    var short: String
    var long: String
    var price: Double
    var priceBTC: Double
    var cap24hrChange: Double
    var marketCap: Double
    var volume: Double
    var supply: Double
    
    private enum CodingKeys: String, CodingKey {
        case short = "id"
        case long = "display_name"
        case price
        case priceBTC = "price_btc"
        case cap24hrChange
        case marketCap = "market_cap"
        case volume
        case supply
    }
    
}
