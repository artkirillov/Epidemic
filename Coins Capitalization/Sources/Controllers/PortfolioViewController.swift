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
        
        items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        
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
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AddCoinViewController") as? AddCoinViewController {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var tableHeaderView: PortfolioTableHeaderView?
    
    private var items: [Asset] = Storage.assets() ?? [] {
        didSet {
            items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        }
    }
    
}

// MARK: - AddCoinViewControllerDelegate

extension PortfolioViewController: AddCoinViewControllerDelegate {
    func addCoinViewController(controller: AddCoinViewController, didAdd asset: Asset) {
        updateInfo()
    }
}

// MARK: - ReduceCoinViewControllerDelegate

extension PortfolioViewController: ReduceCoinViewControllerDelegate {
    func reduceCoinViewController(controller: ReduceCoinViewController, didChange asset: Asset) {
        guard let index = items.index(where: { $0.symbol == asset.symbol }) else { return }
        if asset.totalAmount == 0 {
            items.remove(at: index)
        } else {
            items[index].volume = asset.volume
        }
        tableView.reloadData()
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

// MARK: - UITableViewDelegate

extension PortfolioViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CoinDetailsViewController") as? CoinDetailsViewController {
            controller.symbol = items[indexPath.row].symbol
            controller.name = items[indexPath.row].name
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Updating table

private extension PortfolioViewController {
    
    // MARK: - Private Methods
    
    func updateInfo() {
        
        items = Storage.assets() ?? []
        
        if items.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = "You haven't add any assets to the portfolio"
            noItemsLabel.numberOfLines = 0
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
        
        var currentValue: Double = 0.0
        var value: Double = 0.0
        items.forEach {
            currentValue += $0.currentTotalCost
            value += $0.totalCost
        }
        tableHeaderView?.configure(total: currentValue, value: value, currentValue: currentValue)
        tableView.refreshControl?.endRefreshing()
    }
}
