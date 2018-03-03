//
//  Asset.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Asset: Codable {
    
    var name: String
    var symbol: String
    var volume: [Volume]
    var currentPrice: Double?
    
}

struct Volume: Codable {
    
    var amount: Double
    var price: Double
}
