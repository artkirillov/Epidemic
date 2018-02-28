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
        
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIImageView(image: #imageLiteral(resourceName: "filter"))
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 16)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearSearchTextField), for: .touchUpInside)
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .always
        searchTextFieldClearButton = clearButton
        searchTextFieldClearButton?.isHidden = true
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110.0
        
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
    
    @objc func clearSearchTextField() {
        searchTextField.text = nil
        searchTextFieldClearButton?.isHidden = true
        filteredItems = items
        view.endEditing(true)
    }
    
    func reset() {
        tableView.setContentOffset(.zero, animated: false)
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet weak var marketCapitalizationLabel: UILabel!
    @IBOutlet weak var bitcoinDominanceLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    private var searchTextFieldClearButton: UIButton?
    
    
    private var items: [Ticker] = []
    private var filteredItems: [Ticker] = [] {
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
                if let searchText = self?.searchTextField.text, !searchText.isEmpty {
                    self?.updateItems(withSearchText: searchText)
                } else {
                    self?.filteredItems = tickers
                }
                self?.tableView.refreshControl?.endRefreshing()
            },
            failure: { error in print("ERROR: \(error)")
        })
        
        API.requestGlobalData(
            success: { [weak self] globalData in
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 0
                
                if let text = numberFormatter.string(from: globalData.totalMarketCapUSD as NSNumber) {
                    self?.marketCapitalizationLabel.text = "Market Capitalization: $\(text)"
                } else {
                    self?.marketCapitalizationLabel.text = "Coins"
                }
                
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                
                if let text = numberFormatter.string(from: globalData.bitcoinPercentageOfMarketCap as NSNumber) {
                    self?.bitcoinDominanceLabel.text = "Bitcoin Dominance: \(text)%"
                } else {
                    self?.bitcoinDominanceLabel.text = nil
                }
                
                self?.tableView.refreshControl?.endRefreshing()
            },
            failure: { error in print("ERROR: \(error)")
        })
    }
    
}

// MARK: - UITableViewDataSource

extension CoinsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCell", for: indexPath) as! TickerTableViewCell
        cell.configure(ticker: filteredItems[indexPath.row])
        return cell
    }
    
}

// MARK: - UITextFieldDelegate

extension CoinsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else {
            self.filteredItems = self.items
            return true
        }
        
        updateItems(withSearchText: textFieldText + string)
        searchTextFieldClearButton?.isHidden = (textFieldText + string).isEmpty
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextFieldClearButton?.isHidden = textField.text?.isEmpty ?? true
    }
    
    private func updateItems(withSearchText searchText: String) {
        let filteredItems = items.filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        
        if filteredItems.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = "Can't find any coins"
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        self.filteredItems = filteredItems
    }
    
}
