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
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = NSLocalizedString("Portfolio", comment: "").uppercased()
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        
        tableView.tableFooterView = UIView()
        tableHeaderView = tableView.tableHeaderView as? PortfolioTableHeaderView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
        updateInfo()
    }
    
    @objc func updateData() {
        updateInfo()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    private var tableHeaderView: PortfolioTableHeaderView?
    
    private var items: [Asset] = Storage.assets() ?? [] {
        didSet {
            items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        }
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
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: CoinDetailsViewController.identifier) as? CoinDetailsViewController, let cell = tableView.cellForRow(at: indexPath) {
            
            controller.coin = Storage.coins()?.first { $0.short == items[indexPath.row].symbol }
            
            let height = cell.frame.height
            let width = view.frame.width * height / view.frame.height
            let origin = view.convert(cell.frame.origin, from: tableView)
            let x = (cell.frame.width - width) / 2
            let originFrame = CGRect(x: x, y: origin.y, width: width, height: height)
            controller.originFrame = originFrame
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.reloadData()
        var currentValue: Double = 0.0
        var value: Double = 0.0
        items.forEach {
            currentValue += $0.currentTotalCost
            value += $0.totalCost
        }
        tableHeaderView?.configure(value: value, currentValue: currentValue)
        Storage.save(assets: items)
    }
}

// MARK: - Updating table

private extension PortfolioViewController {
    
    // MARK: - Private Methods
    
    func updateInfo() {
        
        items = Storage.assets() ?? []
        
        let image = UIImage(imageLiteralResourceName: "noAssets")
        let title = NSLocalizedString("Empty portfolio title", comment: "")
        let message = NSLocalizedString("Empty portfolio message", comment: "")
        tableView.backgroundView = items.isEmpty ?
            MessageView(image: image, title: title, message: message, alignment: .center) : nil
        tableView.reloadData()
        
        var currentValue: Double = 0.0
        var value: Double = 0.0
        items.forEach {
            currentValue += $0.currentTotalCost
            value += $0.totalCost
        }
        tableHeaderView?.configure(value: value, currentValue: items.isEmpty ? nil : currentValue)
        tableView.refreshControl?.endRefreshing()
    }
    
}
