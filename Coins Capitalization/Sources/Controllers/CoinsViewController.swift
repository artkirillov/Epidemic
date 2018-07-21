//
//  CoinsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 23.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIImageView(image: #imageLiteral(resourceName: "search"))
        
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
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
        requestData()
    }
    
    @objc func updateData() {
        requestData()
    }
    
    @objc func clearSearchTextField() {
        searchTextField.text = nil
        searchTextFieldClearButton?.isHidden = true
        tableView.backgroundView = nil
        filteredItems = items
        view.endEditing(true)
    }
    
    func reset() {
        tableView.setContentOffset(.zero, animated: false)
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var marketCapitalizationLabel: UILabel!
    @IBOutlet private weak var bitcoinDominanceLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    private var searchTextFieldClearButton: UIButton?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var items: [Ticker] = []
    private var filteredItems: [Ticker] = [] {
        didSet {
            tableView.reloadData()
        }
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

// MARK: - UITableViewDelegate

extension CoinsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CoinDetailsViewController") as? CoinDetailsViewController, let cell = tableView.cellForRow(at: indexPath) {
            controller.symbol = filteredItems[indexPath.row].symbol
            controller.name = filteredItems[indexPath.row].name
            
            let height = cell.frame.height
            let width = view.frame.width * height / view.frame.height
            let origin = view.convert(cell.frame.origin, from: tableView)
            let x = (cell.frame.width - width) / 2
            let originFrame = CGRect(x: x, y: origin.y, width: width, height: height)
            controller.originFrame = originFrame
            
            present(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension CoinsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else {
            self.filteredItems = self.items
            return true
        }
        
        updateItems(withSearchText: string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string)
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
            noItemsLabel.text = NSLocalizedString("Can't find any coins", comment: "")
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        self.filteredItems = filteredItems
    }
    
}

// MARK: - Network Requests

private extension CoinsViewController {
    
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
                self?.activityIndicator?.stopAnimating()
                
                DispatchQueue.global().async {
                    let coins = tickers.map { Coin(id: $0.id, name: $0.name, symbol: $0.symbol, priceUSD: $0.priceUSD) }
                    Storage.save(coins: coins)
                    
                    var assets = Storage.assets() ?? []
                    assets.enumerated().forEach { index, asset in
                        if let coin = coins.first(where: { coin in return coin.symbol == asset.symbol }),
                            let priceUSD = coin.priceUSD {
                            assets[index].currentPrice = Double(priceUSD)
                        }
                    }
                    Storage.save(assets: assets)
                    
                    DispatchQueue.main.async {
                        if let tabBarController = self?.parent as? UITabBarController,
                            let portfolioViewController = tabBarController.viewControllers?[1] as? PortfolioViewController,
                            portfolioViewController.isViewLoaded {
                            portfolioViewController.updateData()
                        }
                    }
                }
            },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
        
        API.requestGlobalData(
            success: { [weak self] globalData in
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                
                if let text = numberFormatter.string(from: round(Double(globalData.totalMarketCapUSD) / 1000000000) as NSNumber) {
                    self?.marketCapitalizationLabel.text = "\(NSLocalizedString("Market Capitalization", comment: "")): $\(text)\(NSLocalizedString("B", comment: ""))"
                    self?.marketCapitalizationLabel.textAlignment = .left
                } else {
                    self?.marketCapitalizationLabel.text = NSLocalizedString("Coins", comment: "")
                }
                
                if let text = numberFormatter.string(from: globalData.bitcoinPercentageOfMarketCap as NSNumber) {
                    self?.bitcoinDominanceLabel.text = "\(NSLocalizedString("Bitcoin Dominance", comment: "")): \(text)%"
                } else {
                    self?.bitcoinDominanceLabel.text = nil
                }
                
                self?.tableView.refreshControl?.endRefreshing()
            },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
        
        API.requestAppStoreData(
            success: { appStoreLookup in
                guard let appId = appStoreLookup.results.first?.appID else { return }
                Storage.save(appId: appId)
        },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
    }
    
}

private extension CoinsViewController {
    
    func stopAnimateActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.activityIndicator?.stopAnimating()
        }
    }
}

