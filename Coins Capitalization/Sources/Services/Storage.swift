//
//  Storage.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 01.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class Storage {
    
    // MARK: - Public Nested
    
    struct Filename {
        static let coins = "Coins.txt"
        static let assets = "Assets.txt"
    }
    
    // MARK: - Public Methods
    
    /// Gets coins from storage
    static func coins() -> [Coin]? {
        return get(from: Filename.coins)
    }
    
    /// Gets assets from storage
    static func assets() -> [Asset]? {
        return get(from: Filename.assets)
    }
    
    /// Saves coins to storage
    static func save(coins: [Coin]) {
        save(coins, in: Filename.coins)
    }
    
    /// Saves assets to storage
    static func save(assets: [Asset]) {
        save(assets, in: Filename.assets)
    }
    
    // MARK: - Private Methods
    
    /// Generic method for saving encodable objects to files
    private static func save<T: Encodable>(_ object: T, in filename: String) {
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let data = try jsonEncoder.encode(object)
            let string = String(data: data, encoding: String.Encoding.utf8)
            
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filepath = path.appendingPathComponent(filename)
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
    
    /// Generic method for getting decodable objects from files
    private static func get<T: Decodable>(from filename: String) -> T? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filepath = path.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: filepath)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let object = try jsonDecoder.decode(T.self, from: data)
                    return object
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
