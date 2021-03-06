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
        items = Storage.coins() ?? []
        favoriteItems = favoriteCoins(from: items)
        filteredItems = items
        filteredFavoriteItems = favoriteItems
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = NSLocalizedString("Cryptocurrencies", comment: "").uppercased()
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        let placeholderString = NSLocalizedString("Search", comment: "")
        searchTextField.attributedPlaceholder = NSAttributedString.attributedTextFieldPlaceholder(string: placeholderString)
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 16)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearSearchTextField), for: .touchUpInside)
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .always
        searchTextField.returnKeyType = .search
        searchTextFieldClearButton = clearButton
        searchTextFieldClearButton?.isHidden = true
        
        collectionView.keyboardDismissMode = .onDrag
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
        animation.type = CATransitionType.fade
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
            .filter { $0.long.lowercased().range(of: searchText.lowercased()) != nil || $0.short.lowercased().range(of: searchText.lowercased()) != nil }
        filteredFavoriteItems = favoriteItemsCountIsBig ? favoriteItems
            .filter { $0.long.lowercased().range(of: searchText.lowercased()) != nil || $0.short.lowercased().range(of: searchText.lowercased()) != nil } : favoriteItems
        
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
    
    private var items: [Coin] = []
    private var filteredItems: [Coin] = []
    
    private var favoriteItems: [Coin] = []
    private var filteredFavoriteItems: [Coin] = []
    
    private var searchText = ""
}

// MARK: - UITextFieldDelegate

extension CoinsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else {
            updateItems(withSearchText: "")
            return true
        }
        
        updateItems(withSearchText: string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextFieldClearButton?.isHidden = false
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
        return collectionView.bounds.size // height 20
    }
    
}

// MARK: - TickerListCollectionViewCellDelegate

extension CoinsViewController: TickerListCollectionViewCellDelegate {
    
    func tickerListCollectionViewCellDidRequestUpdate(cell: TickerListCollectionViewCell) {
        requestData()
    }
    
    func tickerListCollectionViewCell(cell: TickerListCollectionViewCell, didSelectRowAt index: Int, frame: CGRect) {
        if let row = collectionView.indexPath(for: cell)?.row,
            let controller = storyboard?.instantiateViewController(withIdentifier: CoinDetailsViewController.identifier) as? CoinDetailsViewController {
            let coins = row == 0 ? filteredItems : filteredFavoriteItems
            
            controller.coin = coins[index]
            
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
        API.requestCoinsData(
            success: { [weak self] coins in
                let favoriteCoins = self?.favoriteCoins(from: coins) ?? []
                
                self?.items = coins
                self?.favoriteItems = favoriteCoins
                
                if let searchText = self?.searchTextField.text, !searchText.isEmpty {
                    self?.updateItems(withSearchText: searchText)
                } else {
                    self?.filteredItems = coins
                    self?.filteredFavoriteItems = favoriteCoins
                }
                
                self?.collectionView.reloadData()
                
                DispatchQueue.global().async {
                    Storage.save(coins: coins)
                    
                    var assets = Storage.assets() ?? []
                    assets.enumerated().forEach { index, asset in
                        if let coin = coins.first(where: { coin in return coin.short == asset.symbol }) {
                            assets[index].currentPrice = coin.price
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
    
    func favoriteCoins(from coins: [Coin]) -> [Coin] {
        let favoriteCoins = Storage.favoriteCoins()
        return coins.filter { favoriteCoins.contains($0.short) }
    }
    
}
