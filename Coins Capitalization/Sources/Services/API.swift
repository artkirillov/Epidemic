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
        
        var urlComponents: URLComponents? {
            switch self {
            case .ticker: return URLComponents(string: "https://api.coinmarketcap.com/v1/ticker/")
            case .globalData: return URLComponents(string: "https://api.coinmarketcap.com/v1/global/")
            }
        }
        
        var parameters: [String: String]? {
            switch self {
            case .ticker:     return ["limit": "0"]
            case .globalData: return nil
            }
        }
    }
    
    // MARK: - Public Methods
    
    static func requestCoinsData(success: @escaping ([Ticker]) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .ticker, parameters: EndPoint.ticker.parameters, success: success, failure: failure)
    }
    
    static func requestGlobalData(success: @escaping (GlobalData) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .globalData, success: success, failure: failure)
    }
    
    // MARK: - Private Methods
    
    private static func request<T: Decodable>(
        endpoint: EndPoint,
        parameters: [String: String]? = nil,
        success: @escaping (T) -> Void,
        failure: @escaping (Error) -> Void
        )
    {
        guard var urlComponents = endpoint.urlComponents else { return }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
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
