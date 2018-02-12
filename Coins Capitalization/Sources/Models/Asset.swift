//
//  Asset.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Asset {
    
    var name: String
    var symbol: String
    var volume: [(amount: Double, price: Double)]
    var currentPrice: Double
    
}
