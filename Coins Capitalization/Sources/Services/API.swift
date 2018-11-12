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
    
    struct CashKeys {
        static var lastUpdate = "lastUpdate"
    }
    
    enum EndPoint {
        
        case coins
        case coinDetails(symbol: String)
        case chart(type: ChartType, symbol: String)
        case exchanges
        case markets(exchangeId: String?, baseSymbol: String?)
        case appStore
        
        enum ChartType: String {
            case all         = ""
            case year        = "365day"
            case halfYear    = "180day"
            case threeMonths = "90day"
            case month       = "30day"
            case week        = "7day"
            case day         = "1day"
        }
        
        var urlComponents: URLComponents? {
            switch self {
            case .coins:                       return URLComponents(string: "https://coincap.io/front")
            case .coinDetails(let symbol):     return URLComponents(string: "https://coincap.io/page/\(symbol)")
            case .chart(let type, let symbol):
                if type == .all {              return URLComponents(string: "https://coincap.io/history/\(symbol)") }
                else {                         return URLComponents(string: "https://coincap.io/history/\(type.rawValue)/\(symbol)") }
            case .exchanges:                   return URLComponents(string: "https://api.coincap.io/v2/exchanges")
            case .markets:                     return URLComponents(string: "https://api.coincap.io/v2/markets")
            case .appStore:                    return URLComponents(string: "https://itunes.apple.com/lookup")
            }
        }
        
        var parameters: [String: String]? {
            switch self {
            case .markets(let exchangeId, let baseSymbol):
                var params: [String: String] = [:]
                exchangeId.flatMap { params["exchangeId"] = $0 }
                baseSymbol.flatMap { params["baseSymbol"] = $0 }
                return params
            case .appStore:   return ["bundleId": Bundle.main.bundleIdentifier ?? ""]
            default: return nil
            }
        }
        
        var cacheExpirationInSeconds: Int {
            switch self {
            case .coins, .coinDetails: return 10
            case .chart:               return 600
            case .exchanges, .markets: return 3600
            case .appStore:            return Int.max
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests all coins data from Coin Cap IO API
    static func requestCoinsData(success: @escaping ([Coin]) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .coins, success: success, failure: failure)
    }
    
    /// Requests coin details from Coin Cap IO API
    static func requestCoinDetails(for symbol: String, success: @escaping (CoinDetails) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .coinDetails(symbol: symbol), success: success, failure: failure)
    }
    
    /// Requests chart data from Coin Cap IO API
    static func requestChartData(type: EndPoint.ChartType, for symbol: String,
                                 success: @escaping (ChartData) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .chart(type: type, symbol: symbol), success: success, failure: failure)
    }
    
    /// Requests AppStore appId
    static func requestAppStoreData(success: @escaping (AppStoreLookup) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .appStore, parameters: EndPoint.appStore.parameters, success: success, failure: failure)
    }
    
    /// Requests exchanges from Coin Cap IO API
    static func requestExchanges(success: @escaping (Exchanges) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .exchanges, success: success, failure: failure)
    }
    
    /// Requests markets from Coin Cap IO API
    static func requestMarkets(exchangeId: String?, baseSymbol: String?, success: @escaping (Markets) -> Void, failure: @escaping (Error) -> Void) {
        let endPoint = EndPoint.markets(exchangeId: exchangeId, baseSymbol: baseSymbol)
        request(endpoint: endPoint, parameters: endPoint.parameters, success: success, failure: failure)
    }
    
    /// Cancel all active tasks
    static func cancelAllTasks() {
        URLSession.shared.invalidateAndCancel()
    }
    
    // MARK: - Private Methods
    
    /// Generic request method
    private static func request<T: Decodable>(
        endpoint: EndPoint,
        parameters: [String: String]? = nil,
        success: @escaping (T) -> Void,
        failure: @escaping (Error) -> Void
        )
    {
        DispatchQueue.global().async {
            if let cachedData: T = Storage.getCache(for: endpoint) {
                DispatchQueue.main.async { success(cachedData) }
                return
            }
            
            guard var urlComponents = endpoint.urlComponents else { return }
            
            if let parameters = parameters {
                urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            }
            
            guard let url = urlComponents.url else { return }
            
            let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                guard error == nil else {
                    print("ERROR: \(String(describing: error))")
                    failure(error!)
                    return
                }
                
                guard let data = data else {
                    print("NO DATA")
                    return
                }
                
                Storage.saveToCache(for: endpoint, data: data)
                
                let jsonDecoder = JSONDecoder()
                
                do {
                    let object = try jsonDecoder.decode(T.self, from: data)
                    DispatchQueue.main.async { success(object) }
                } catch {
                    DispatchQueue.main.async { failure(error) }
                    print("ERROR: \(String(describing: error))")
                }
                
                
            }
            
            task.resume()
        }
    }
}
