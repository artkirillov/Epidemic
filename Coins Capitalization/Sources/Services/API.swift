//
//  APIManager.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 28.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class API {
    
    // MARK: - Public Nested
    
    enum EndPoint {
        case ticker
        case globalData
        
        var url: URL? {
            switch self {
            case .ticker: return URL(string: "https://api.coinmarketcap.com/v1/ticker/")
            case .globalData: return URL(string: "https://api.coinmarketcap.com/v1/global/")
            }
        }
    }
    
    // MARK: - Public Methods
    
    static func requestCoinsData(success: @escaping ([Ticker]) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .ticker, success: success, failure: failure)
    }
    
    static func requestGlobalData(success: @escaping (GlobalData) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .globalData, success: success, failure: failure)
    }
    
    // MARK: - Private Methods
    
    private static func request<T: Decodable>(
        endpoint: EndPoint,
        success: @escaping (T) -> Void,
        failure: @escaping (Error) -> Void
        )
    {
        guard let url = endpoint.url else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, request, error in
            guard error == nil else {
                print("ERROR: \(error!.localizedDescription)")
                failure(error!)
                return
            }
            
            guard let data = data else {
                // handle error
                print("NO DATA")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let object = try jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    success(object)
                }
            } catch {
                failure(error)
            }
        }
        
        task.resume()
    }
}
