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
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "exchangeId"
        case name
    }
}
