//
//  Exchange.swift
//  Coins
//
//  Created by Artem Kirillov on 11/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Exchanges: Codable {
    var data: [Exchange]
}

struct Exchange: Codable {
    
    var exchangeId: String
    var name: String
    
}
