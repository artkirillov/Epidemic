//
//  PortfolioViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 09.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        updateInfo()
    }
    
    func reset() {
        tableView.setContentOffset(.zero, animated: false)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        print("--- Open screen to add new asset")
    }
    
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    
    private var items: [Asset] = [] {
        didSet {
            updateInfo()
        }
    }
    
}

private extension PortfolioViewController {
    
    // MARK: - Private Methods
    
    func updateInfo() {
        if items.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = "You hasn't add any assets into portfolio"
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension PortfolioViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as! AssetTableViewCell
        //cell.configure(asset: items[indexPath.row])
        return cell
    }
    
}
