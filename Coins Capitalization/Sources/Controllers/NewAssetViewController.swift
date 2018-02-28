//
//  NewAssetViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 19.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

class NewAssetViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Section: String {
        case coin = "Coin"
        case deal = "Deal"
    }
    
    enum Row: String {
        case coin          = "Coin"
        case numberOfDeals = "Number of deals"
        case amount        = "Amount"
        case price         = "Price"
    }
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private properties
    
    @IBOutlet private var tableView: UITableView!
    
    private var asset: Asset = Asset(name: "Bitcoin", symbol: "BTC", volume: [(0, 0)], currentPrice: 0.0)
    private var numberOfDeals: Int = 1
    
}

extension NewAssetViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
