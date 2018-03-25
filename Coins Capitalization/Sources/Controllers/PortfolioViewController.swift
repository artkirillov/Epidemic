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
        let maxFreeVolume = Storage.maxPortfolioVolume()
        
        if items.count < maxFreeVolume {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AddCoinViewController") as? AddCoinViewController {
                controller.delegate = self
                present(controller, animated: true, completion: nil)
            }
        } else if maxFreeVolume == 3 {
            let alertController = UIAlertController(title: NSLocalizedString("Free trial alert", comment: ""),
                                                    message: NSLocalizedString("Free trial message", comment: ""),
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Go to AppStore", comment: ""), style: .default, handler: { _ in
                if let appId = Storage.appId(), let url = URL(string: "https://itunes.apple.com/app/id\(appId)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in Storage.save(maxPortfolioVolume: 5) })
                } else if let url = URL(string: "https://www.apple.com/itunes/") {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in Storage.save(maxPortfolioVolume: 5) })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { _ in alertController.dismiss(animated: true, completion: nil) }))
            
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("Pro alert", comment: ""),
                                                    message: NSLocalizedString("Pro message", comment: ""),
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { _ in
//                if let parentViewController = self?.parent as? UITabBarController,
//                    let count = parentViewController.viewControllers?.count {
//                    parentViewController.selectedIndex = count - 1
//                }
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: { _ in alertController.dismiss(animated: true, completion: nil) }))
            
            present(alertController, animated: true, completion: nil)
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
            noItemsLabel.text = NSLocalizedString("You haven't add any assets to the portfolio", comment: "")
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
