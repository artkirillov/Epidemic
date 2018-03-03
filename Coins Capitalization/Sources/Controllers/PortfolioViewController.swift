//
//  PortfolioViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 09.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class PortfolioViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableHeaderView = tableView.tableHeaderView as? PortfolioTableHeaderView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         updateInfo()
    }
    
    @objc func updateData() {
        updateInfo()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let controller = storyboard.instantiateViewController(withIdentifier: "NewDealViewController") as? NewDealViewController {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var tableHeaderView: PortfolioTableHeaderView?
    
    private var items: [Asset] = Storage.assets() ?? [] {
        didSet {
            updateInfo()
        }
    }
    
}

// MARK: - NewDealViewControllerDelegate

extension PortfolioViewController: NewDealViewControllerDelegate {
    func newDealViewController(controller: NewDealViewController, didAdd asset: Asset) {
        if let index = items.index(where: { $0.symbol == asset.symbol }) {
            items[index].volume += asset.volume
        } else {
            items.append(asset)
        }
        Storage.save(assets: items)
    }
}

// MARK: - UITableViewDataSource

extension PortfolioViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as! AssetTableViewCell
        cell.configure(asset: items[indexPath.row])
        return cell
    }
    
}

// MARK: - Updating table

private extension PortfolioViewController {
    
    // MARK: - Private Methods
    
    func updateInfo() {
        if items.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = "You haven't add any assets to the portfolio"
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
        
        var currentValue: Double = 0.0
        var value: Double = 0.0
        for item in items {
            let volume = item.volume.reduce(0.0) { $0 + $1.amount }
            let price = item.currentPrice ?? 0
            currentValue += volume * price
            value += item.volume.reduce(0.0) { $0 + $1.amount * $1.price }
        }
        tableHeaderView?.configure(total: currentValue, profit: currentValue / value)
        tableView.refreshControl?.endRefreshing()
    }
}
