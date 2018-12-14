//
//  CoinDetailsViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 10.10.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinDetailsViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Row {
        case chart
        case infoHeader(text: String)
        case singleInfo(title: String, value: String)
        case doubleInfo(titleOne: String, valueOne: String, titleTwo: String, valueTwo: String)
        case button(title: String)
    }
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: CoinDetailsViewController.self)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var coin: Coin?
    
    var isFavorite: Bool = false {
        didSet {
            favoriteButton.setImage(isFavorite ? #imageLiteral(resourceName: "heart_full") : #imageLiteral(resourceName: "heart_empty"), for: .normal)
        }
    }
    
    var rows: [Row] = [.chart]
    
    // Custom Transition parameters
    
    var originFrame = CGRect.zero
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFavorite = Storage.favoriteCoins().contains(coin?.short ?? "")
        
        view.backgroundColor = Colors.backgroundColor
        
        titleLabel.attributedText = coin.flatMap { NSAttributedString.attributedTitle(string: $0.long.uppercased()) }
        
        tableHeaderView = tableView.tableHeaderView as? PortfolioTableHeaderView
        coin.flatMap { tableHeaderView?.configure(value: nil, currentValue: $0.price) }
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: 30.0))
        tableView.register(ChartTableViewCell.self, forCellReuseIdentifier: ChartTableViewCell.identifier)
        tableView.register(UINib(nibName: InfoHeaderCell.identifier, bundle: nil), forCellReuseIdentifier: InfoHeaderCell.identifier)
        tableView.register(UINib(nibName: SingleInfoCell.identifier, bundle: nil), forCellReuseIdentifier: SingleInfoCell.identifier)
        tableView.register(UINib(nibName: DoubleInfoCell.identifier, bundle: nil), forCellReuseIdentifier: DoubleInfoCell.identifier)
        tableView.register(UINib(nibName: ButtonCell.identifier, bundle: nil), forCellReuseIdentifier: ButtonCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150.0
        
        transitioningDelegate = self
        
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        isFavorite = !isFavorite
        feedBackGenerator.impactOccurred()
        
        var favoriteCoins = Storage.favoriteCoins()
        
        if isFavorite {
            if let symbol = coin?.short { favoriteCoins.append(symbol) }
        } else {
            favoriteCoins = favoriteCoins.filter { $0 != coin?.short }
        }
        
        Storage.save(favoriteCoins: favoriteCoins)
    }
    
    
    
    // MARK: - Private Properties
    
    private let feedBackGenerator = UIImpactFeedbackGenerator()
    private var tableHeaderView: PortfolioTableHeaderView?
    
    @IBOutlet private var favoriteButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    private var lastContentOffset: CGFloat = 0.0
    private let contentOffsetThreshold: CGFloat = 37.0
    private let animation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = CATransitionType.fade
        return animation
    }()
    
    private let storeManager = StoreManager()
    
}

// MARK: - UITableViewDataSource

extension CoinDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .chart:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCell.identifier, for: indexPath) as? ChartTableViewCell, let coin = coin else { return UITableViewCell() }
            cell.configure(coin: coin, delegate: self)
            return cell
            
        case .infoHeader(let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoHeaderCell.identifier, for: indexPath) as? InfoHeaderCell else { return UITableViewCell() }
            cell.configure(text: text)
            return cell
            
        case .singleInfo(let title, let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SingleInfoCell.identifier, for: indexPath) as? SingleInfoCell else { return UITableViewCell() }
            cell.configure(title: title, value: value)
            return cell
            
        case .doubleInfo(let titleOne, let valueOne, let titleTwo, let valueTwo):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DoubleInfoCell.identifier, for: indexPath) as? DoubleInfoCell else { return UITableViewCell() }
            cell.configure(titleOne: titleOne, valueOne: valueOne, titleTwo: titleTwo, valueTwo: valueTwo)
            return cell
            
        case .button(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else { return UITableViewCell() }
            cell.configure(title: title, delegate: self)
            return cell
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension CoinDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return CustomViewControllerAnimator(duration: 0.2, isPresenting: true, originFrame: originFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomViewControllerAnimator(duration: 0.2, isPresenting: false, originFrame: originFrame)
    }
}

// MARK: - ChartTableViewCellDelegate

extension CoinDetailsViewController: ChartTableViewCellDelegate {
    
    func chartTableViewCell(cell: ChartTableViewCell, changedPeriodWithPrice value: Double?) {
        guard let currentPrice = coin?.price else { return }
        tableHeaderView?.configure(value: value, currentValue: currentPrice)
    }
    
}

// MARK: - ButtonCellDelegate

extension CoinDetailsViewController: ButtonCellDelegate {
    
    func buttonCellDidTouched(cell: ButtonCell) {
        let maxFreeVolume = Storage.maxPortfolioVolume()
        let assets = Storage.assets() ?? []
        
        if !assets.contains(where: { $0.symbol == coin?.short }) || assets.count < maxFreeVolume {
            if let controller = storyboard?.instantiateViewController(withIdentifier: NewTransactionViewController.identifier) as? NewTransactionViewController {
                controller.coin = coin
                present(controller, animated: true, completion: nil)
            }
        } else if maxFreeVolume == 3 {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = NSLocalizedString("Free trial alert", comment: "")
                controller.message = NSLocalizedString("Free trial message", comment: "")
                controller.image = #imageLiteral(resourceName: "review")
                
                controller.addAction(
                    title: NSLocalizedString("Go to AppStore", comment: ""),
                    handler: { [weak controller] in
                        if let appId = Storage.appId(), let url = URL(string: "https://itunes.apple.com/app/id\(appId)") {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                                Storage.save(maxPortfolioVolume: 5)
                                controller?.dismiss(animated: true, completion: nil)
                            })
                        } else if let url = URL(string: "https://www.apple.com/itunes/") {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                                Storage.save(maxPortfolioVolume: 5)
                                controller?.dismiss(animated: true, completion: nil)
                            })
                        }
                })
                
                controller.addAction(
                    title: NSLocalizedString("Cancel", comment: ""),
                    handler: { [weak controller] in controller?.dismiss(animated: true, completion: nil) })
                
                present(controller, animated: true, completion: nil)
            }
        } else {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = NSLocalizedString("Pro alert", comment: "")
                controller.image = #imageLiteral(resourceName: "check")
                
                var message: String = ""
                var okButtonTitle: String = ""
                var cancelButtonTitle: String = ""
                if let product = storeManager.unlimitedPortfolioProduct, storeManager.canMakePayments() {
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = product.priceLocale
                    let formattedPrice = numberFormatter.string(from: product.price) ?? "\(product.price)"
                    
                    message = NSLocalizedString("Pro message and payment", comment: "") + " \(formattedPrice)."
                    okButtonTitle = NSLocalizedString("Let's try it", comment: "")
                    cancelButtonTitle = NSLocalizedString("No, thanks", comment: "")
                } else {
                    message = NSLocalizedString("Pro message", comment: "")
                    okButtonTitle = NSLocalizedString("Ok", comment: "")
                    cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
                }
                
                controller.message = message
                
                controller.addAction(
                    title: okButtonTitle,
                    handler: { [weak self, weak controller] in
                        self?.storeManager.unlimitedPortfolioProduct.flatMap { self?.storeManager.makePayment(with: $0) }
                        controller?.dismiss(animated: true, completion: nil)
                })
                
                controller.addAction(
                    title: cancelButtonTitle,
                    handler: { [weak controller] in
                        controller?.dismiss(animated: true, completion: nil)
                })
                
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - UIScrollViewDelegate

extension CoinDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y - contentOffsetThreshold) * (lastContentOffset - contentOffsetThreshold) <= 0 {
            titleLabel.layer.add(animation, forKey: kCATransition)
            titleLabel.attributedText = coin.flatMap {
                if let price = Formatter.format($0.price, maximumFractionDigits: Formatter.maximumFractionDigits(for: $0.price)) {
                    let title = scrollView.contentOffset.y > contentOffsetThreshold ? "\($0.long) - $\(price)" : $0.long
                    return NSAttributedString.attributedTitle(string: title.uppercased())
                } else {
                    return NSAttributedString.attributedTitle(string: $0.long.uppercased())
                }
            }
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
    
}

// MARK: - Network Requests

private extension CoinDetailsViewController {
    
    func makeRows(coinDetails: CoinDetails) -> [Row] {
        
        let marketCapValue = Formatter
            .format(coinDetails.marketCap, maximumFractionDigits: Formatter.maximumFractionDigits(for: coinDetails.marketCap))
            .flatMap { "$ \($0)" }
        
        let volumeValue = Formatter.format(coinDetails.volume, maximumFractionDigits: 0).flatMap { "\($0) \(coin?.short ?? "")" }
        let supplyValue = Formatter.format(coinDetails.supply, maximumFractionDigits: 0).flatMap { "\($0) \(coin?.short ?? "")" }
        
        var rows: [Row] = [
            .chart,
            .infoHeader(text: NSLocalizedString("Statistics", comment: "")),
            .singleInfo(title: NSLocalizedString("Market Capitalization", comment: ""),
                        value: marketCapValue ?? ""),
            .singleInfo(title: NSLocalizedString("Volume", comment: ""),
                        value: volumeValue ?? ""),
            .singleInfo(title: NSLocalizedString("Supply", comment: ""),
                        value: supplyValue ?? ""),
        ]
        
        if let coin = coin, let asset = Storage.assets()?.first(where: { $0.symbol == coin.short }) {
            
            let amountValue = Formatter.format(asset.totalAmount, maximumFractionDigits: 5).flatMap { "\($0) \(coin.short)" }
            let costValue = Formatter
                .format(asset.currentTotalCost, maximumFractionDigits: Formatter.maximumFractionDigits(for: asset.currentTotalCost))
                .flatMap { "$ \($0)" }
            
            var assetRows: [Row] = [
                .infoHeader(text: NSLocalizedString("Portfolio", comment: "")),
                .doubleInfo(titleOne: NSLocalizedString("Quantity", comment: ""),
                           valueOne: amountValue ?? "",
                           titleTwo: NSLocalizedString("Cost", comment: ""),
                           valueTwo: costValue ?? "")
            ]
                
            let absoluteProfit = asset.currentTotalCost - asset.totalCost
            let relativeProfit = absoluteProfit / asset.totalCost * 100
            
            if let profitText = Formatter.format(absoluteProfit, maximumFractionDigits: Formatter.maximumFractionDigits(for: absoluteProfit)),
                let percentText = Formatter.format(relativeProfit) {
                
                let symbol = absoluteProfit == 0 ? "" : absoluteProfit > 0 ? "↑" : "↓"
                assetRows.append(.singleInfo(title: NSLocalizedString("24HChange", comment: ""),
                                             value: "\(symbol) $\(profitText) (\(percentText)%)"))
            }
            
            rows.append(contentsOf: assetRows)
        }
        
        rows.append(.button(title: NSLocalizedString("New Transaction", comment: "")))
        
        return rows
    }
    
    func requestData() {
        guard let coin = coin else { return }
        API.requestCoinDetails(
            for: coin.short,
            success: { [weak self] coinDetails in
                guard let slf = self else { return }
                slf.rows = slf.makeRows(coinDetails: coinDetails)
                slf.tableView.layer.add(slf.animation, forKey: kCATransition)
                slf.tableView.reloadData()
        },
            failure: { [weak self] error in
                guard let slf = self else { return }
                
                slf.rows = [.chart, .button(title: NSLocalizedString("New Transaction", comment: ""))]
                slf.tableView.layer.add(slf.animation, forKey: kCATransition)
                slf.tableView.reloadData()
        })
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
