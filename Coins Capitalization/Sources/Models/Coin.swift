//
//  Coin.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 23.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Coin: Codable {
    
    var short: String
    var long: String
    var price: Double
    var cap24hrChange: Double
    
}
