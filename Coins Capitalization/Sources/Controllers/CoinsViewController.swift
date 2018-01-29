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
        tableViewHeader = tableView.tableHeaderView as? GlobalDataTableHeaderView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestData()
    }
    
    @objc func updateData() {
        requestData()
    }
    
    func reset() {
        tableView.setContentOffset(.zero, animated: false)
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var tableViewHeader: GlobalDataTableHeaderView!
    
    private var items: [Ticker] = [] {
        didSet {
            tableView.reloadData()
        }
    }

}

// MARK: - Network Requests

fileprivate extension CoinsViewController {
    
    func requestData() {
        API.requestCoinsData(
            success: { [weak self] tickers in
                self?.items = tickers
                self?.tableView.refreshControl?.endRefreshing()
            },
            failure: { error in print("ERROR: \(error.localizedDescription)")
        })
        
        API.requestGlobalData(
            success: { [weak self] globalData in
                self?.tableViewHeader.configure(capitalization: globalData.totalMarketCapUSD)
                self?.tableView.refreshControl?.endRefreshing()
            },
            failure: { error in print("ERROR: \(error.localizedDescription)")
        })
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
