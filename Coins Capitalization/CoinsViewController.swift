//
//  CoinsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 23.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class CoinsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        sendRequest()
    }

    // MARK: -
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    
    private var items: [Ticker] = [] {
        didSet {
            tableView.reloadData()
        }
    }

}

// MARK: - Network Requests

fileprivate extension CoinsViewController {
    
    func sendRequest() {
        guard let url = URL(string: "https://api.coinmarketcap.com/v1/ticker/") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, request, error in
            guard error == nil else {
                // handle error
                print("ERROR: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                // handle error
                print("NO DATA")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let tickers = try jsonDecoder.decode([Ticker].self, from: data)
                DispatchQueue.main.async {
                    self?.items = tickers
                }
            } catch {
                print("Decoding failed")
                print("ERROR: \(error)")
            }
        }
        
        task.resume()
        
    }
}

// MARK: - UITableViewDataSource

extension CoinsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerTableViewCell
        cell.configure(ticker: items[indexPath.row])
        return cell
    }
    
}

