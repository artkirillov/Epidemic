//
//  Storage.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 01.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class Storage {
    
    struct Filename {
        static let coins = "Coins.txt"
    }
    
    static func save(coins: [Coin]) {
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let data = try jsonEncoder.encode(coins)
            let string = String(data: data, encoding: String.Encoding.utf8)
            
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filepath = path.appendingPathComponent(Filename.coins)
                do {
                    try string?.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    static func coins() -> [Coin]? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filepath = path.appendingPathComponent(Filename.coins)
            do {
                let data = try Data(contentsOf: filepath)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let coins = try jsonDecoder.decode([Coin].self, from: data)
                    return coins
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
}
