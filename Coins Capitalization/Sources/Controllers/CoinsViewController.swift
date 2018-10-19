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
        
        // Initial state from storage
        items = Storage.tickers() ?? []
        favoriteItems = favoriteTickers(fromTickers: items)
        filteredItems = items
        filteredFavoriteItems = favoriteItems
        
        view.backgroundColor = Colors.backgroundColor
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: NSLocalizedString("Cryptocurrencies", comment: "").uppercased())
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Search", comment: ""),
            attributes: [
                .font: Fonts.messageText,
                .foregroundColor: Colors.minorTextColor]
        )
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 16)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearSearchTextField), for: .touchUpInside)
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .always
        searchTextFieldClearButton = clearButton
        searchTextFieldClearButton?.isHidden = true
        
        collectionView.register(TickerListCollectionViewCell.self, forCellWithReuseIdentifier: "TickerListCollectionViewCell")
        
        segmentControl.items = [NSLocalizedString("All", comment: "").uppercased(),
                                NSLocalizedString("Favorite", comment: "").uppercased()]
        segmentControl.thumb = .line
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
        filteredFavoriteItems = favoriteItems
        collectionView.reloadData()
        view.endEditing(true)
    }
    
    @IBAction func changeCoinList(_ sender: SegmentedControl) {
        
        // If segmented control changed we scroll collection view
        collectionView.scrollToItem(at: IndexPath(row: sender.selectedIndex, section: 0),
                                    at: .centeredHorizontally, animated: true)
        
        // and update search text fiels visibility
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = kCATransitionFade
        searchTextField.layer.add(animation, forKey: kCATransition)
        searchTextField.alpha = sender.selectedIndex == 0 || !favoriteItemsCountIsBig ? 1.0 : 0.0
    }
    
    func updateItems(withSearchText searchText: String) {
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            filteredItems = items
            filteredFavoriteItems = favoriteItems
            collectionView.reloadData()
            return
        }
        
        filteredItems = items
            .filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        filteredFavoriteItems = favoriteItems
            .filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        
        collectionView.reloadData()
    }
    
    func reset() {
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var segmentControl: SegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var searchTextFieldClearButton: UIButton?
    
    private var items: [Ticker] = []
    private var filteredItems: [Ticker] = []
    
    private var favoriteItems: [Ticker] = []
    private var filteredFavoriteItems: [Ticker] = []
    
    private var searchText = ""
}

// MARK: - UITextFieldDelegate

extension CoinsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else {
            updateItems(withSearchText: "")
            return true
        }
        
        searchText = string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string
        
        updateItems(withSearchText: searchText)
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
    
}

// MARK: - UICollectionViewDataSource

extension CoinsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TickerListCollectionViewCell", for: indexPath) as! TickerListCollectionViewCell
        
        let emptyResultsTitle = !searchText.isEmpty ? NSLocalizedString("Empty search results title", comment: "") : ""
        let emptyResultsMessage = !searchText.isEmpty ? NSLocalizedString("Empty search results message", comment: "") : ""
        let emptyResultsImage = !searchText.isEmpty ? UIImage(imageLiteralResourceName: "noSearchResults") : nil
        
        if indexPath.row == 0 {
            cell.configure(items: filteredItems, image: emptyResultsImage,
                           noItemsTitle: emptyResultsTitle, noItemsMessage: emptyResultsMessage)
        } else if indexPath.row == 1 {
            let noItemsTitle = favoriteItems.isEmpty ?
                NSLocalizedString("Empty favorites title", comment: "") :
                emptyResultsTitle
            let noItemsMessage = favoriteItems.isEmpty ?
                NSLocalizedString("Empty favorites message", comment: "") :
            emptyResultsMessage
            let image = UIImage(imageLiteralResourceName: "noFavoriteItems")
            cell.configure(items: filteredFavoriteItems, image: image, noItemsTitle: noItemsTitle, noItemsMessage: noItemsMessage)
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension CoinsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let progress = scrollView.contentOffset.x / (scrollView.contentSize.width - collectionView.bounds.width)
        segmentControl.thumbProgress = progress
        
        searchTextField.alpha = favoriteItemsCountIsBig ? 1.0 : 1 - progress
    }
    
}

// MARK: - UICollectionViewDelegate

extension CoinsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

// MARK: - TickerListCollectionViewCellDelegate

extension CoinsViewController: TickerListCollectionViewCellDelegate {
    
    func tickerListCollectionViewCellDidRequestUpdate(cell: TickerListCollectionViewCell) {
        requestData()
    }
    
    func tickerListCollectionViewCell(cell: TickerListCollectionViewCell, didSelectRowAt index: Int, frame: CGRect) {
        if let row = collectionView.indexPath(for: cell)?.row,
            let controller = storyboard?.instantiateViewController(withIdentifier: "CoinInfoViewController") as? CoinInfoViewController {
            let tickers = row == 0 ? filteredItems : filteredFavoriteItems
            
            controller.coin = Coin(ticker: tickers[index])
            
            let height = frame.height
            let width = view.frame.width * height / view.frame.height
            let origin = view.convert(frame.origin, from: cell)
            let x = (frame.width - width) / 2
            let originFrame = CGRect(x: x, y: origin.y, width: width, height: height)
            controller.originFrame = originFrame
            
            present(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Network Requests

private extension CoinsViewController {
    
    func requestData() {
        API.requestTickersData(
            success: { [weak self] tickers in
                let favoriteTickers = self?.favoriteTickers(fromTickers: tickers) ?? []
                
                self?.items = tickers
                self?.favoriteItems = favoriteTickers
                
                if let searchText = self?.searchTextField.text, !searchText.isEmpty {
                    self?.updateItems(withSearchText: searchText)
                } else {
                    self?.filteredItems = tickers
                    self?.filteredFavoriteItems = favoriteTickers
                }
                
                self?.collectionView.reloadData()
                
                DispatchQueue.global().async {
                    Storage.save(tickers: tickers)
                    
                    let coins = tickers.map { Coin(ticker: $0) }
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
/*
        API.requestGlobalData(
            success: { [weak self] globalData in
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                
                if let text = numberFormatter.string(from: round(Double(globalData.totalMarketCapUSD) / 1000000000) as NSNumber) {
                    self?.marketCapitalizationLabel.text = "\(NSLocalizedString("Market Capitalization", comment: "")): $\(text)\(NSLocalizedString("B", comment: ""))"
                    self?.marketCapitalizationLabel.textAlignment = .left
                } else {
                    self?.marketCapitalizationLabel.text = NSLocalizedString("Coins", comment: "").uppercased()
                }
                
                if let text = numberFormatter.string(from: globalData.bitcoinPercentageOfMarketCap as NSNumber) {
                    //self?.bitcoinDominanceLabel.text = "\(NSLocalizedString("Bitcoin Dominance", comment: "")): \(text)%"
                } else {
                    //self?.bitcoinDominanceLabel.text = nil
                }
            },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
 */
        
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
    
    var favoriteItemsCountIsBig: Bool {
        return favoriteItems.count >= 7
    }
    
    func stopAnimateActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.visibleCells.forEach {
                if let tableCell = $0 as? TickerListCollectionViewCell { tableCell.stopRefreshing() }
            }
        }
    }
    
    func favoriteTickers(fromTickers tickers: [Ticker]) -> [Ticker] {
        let favoriteCoins = Storage.favoriteCoins()
        return tickers.filter { favoriteCoins.contains($0.symbol) }
    }
    
}
