//
//  CoinInfoViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 10.10.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinInfoViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Row {
        case chart
        case info
        case buttons
        
        static let allValues: [Row] = [.chart]
    }
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var coin: Coin?
    
    var isFavorite: Bool = false {
        didSet {
            favoriteButton.setImage(isFavorite ? #imageLiteral(resourceName: "heart_full") : #imageLiteral(resourceName: "heart_empty"), for: .normal)
        }
    }
    
    // Custom Transition parameters
    
    var originFrame = CGRect.zero
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFavorite = Storage.favoriteCoins().contains(coin?.symbol ?? "")
        
        view.backgroundColor = Colors.backgroundColor
        
        titleLabel.attributedText = coin.flatMap { NSAttributedString.attributedTitle(string: $0.name.uppercased()) }
        
        tableHeaderView = tableView.tableHeaderView as? PortfolioTableHeaderView
        tableHeaderView?.clear()
        tableView.tableFooterView = UIView()
        tableView.register(ChartTableViewCell.self, forCellReuseIdentifier: ChartTableViewCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        
        transitioningDelegate = self
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
            if let symbol = coin?.symbol { favoriteCoins.append(symbol) }
        } else {
            favoriteCoins = favoriteCoins.filter { $0 != coin?.symbol }
        }
        
        Storage.save(favoriteCoins: favoriteCoins)
    }
    
    
    
    // MARK: - Private Properties
    
    private let feedBackGenerator = UIImpactFeedbackGenerator()
    private var tableHeaderView: PortfolioTableHeaderView?
    
    @IBOutlet private var favoriteButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
}

// MARK: - UITableViewDataSource

extension CoinInfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Row.allValues[indexPath.row]
        switch row {
        case .chart:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCell.identifier, for: indexPath) as? ChartTableViewCell,
                let coin = coin else { return UITableViewCell() }
            
            cell.configure(coin: coin, delegate: self)
            return cell
        case .info: return UITableViewCell()
        case .buttons: return UITableViewCell()
        }
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension CoinInfoViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return CustomViewControllerAnimator(duration: 0.2, isPresenting: true, originFrame: originFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomViewControllerAnimator(duration: 0.2, isPresenting: false, originFrame: originFrame)
    }
}

// MARK: - ChartTableViewCellDelegate

extension CoinInfoViewController: ChartTableViewCellDelegate {
    
    func chartTableViewCell(cell: ChartTableViewCell, changedPeriodWithMinPrice value: Double, maxPrice currentValue: Double) {
        guard let priceUSD = coin?.priceUSD, let total = Double(priceUSD) else { return }
        tableHeaderView?.configure(total: total, value: value, currentValue: currentValue)
    }
}


private extension CoinInfoViewController {
    
    // MARK: - Private Methods
    
    func setupViews() {
        
        
    }
    
    func setupConstraints() {
        
    }
    
}
