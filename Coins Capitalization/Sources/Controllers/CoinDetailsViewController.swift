//
//  CoinDetailsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinDetailsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var symbol: String?
    var name: String?
    weak var delegate: SellCoinViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
        segmentedControl.selectedIndex = 0
        
        animation.duration = 0.2
        animation.type = kCATransitionFade
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = chartView.center
        activityIndicator?.startAnimating()
        
        requestData(for: .day)
    }
    
    @objc func handleSwipe() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeChartType(_ sender: SegmentedControl) {
        activityIndicator?.startAnimating()
        switch sender.selectedIndex {
        case 0: requestData(for: .day)
        case 1: requestData(for: .week)
        case 2: requestData(for: .month)
        case 3: requestData(for: .threeMonths)
        case 4: requestData(for: .halfYear)
        case 5: requestData(for: .year)
        case 6: requestData(for: .all)
        default: break
        }
    }
    
    // MARK: - Private properties
    
    private let animation = CATransition()
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var chartView: ChartView!
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    private var activityIndicator: UIActivityIndicatorView?
}

// MARK: - Network Requests

private extension CoinDetailsViewController {
    
    func requestData(for type: API.EndPoint.ChartType) {
        guard let symbol = symbol else { return }
        API.requestChartData(type: type, for: symbol,
                             success: { [weak self] chartData in
                                guard let slf = self else { return }
                                slf.chartView.layer.add(slf.animation, forKey: kCATransition)
                                slf.chartView.data = chartData.price.map { $0[1] }
                                slf.setChangeValue(firstValue: chartData.price.first?[1], lastValue: chartData.price.last?[1])
                                slf.activityIndicator?.stopAnimating()
            },
                             failure: { error in print("ERROR: \(error)")
        })
    }
    
    func setChangeValue(firstValue: Double?, lastValue: Double?) {
        if let firstValue = firstValue, let lastValue = lastValue {
            let absoluteProfit = lastValue - firstValue
            let relativeProfit = absoluteProfit / firstValue * 100
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            let profitText = numberFormatter.string(from: abs(absoluteProfit) as NSNumber) ?? "---"
            let percentText = numberFormatter.string(from: abs(relativeProfit) as NSNumber) ?? "---"
            
            if absoluteProfit > 0 {
                changeLabel.text = "↑ $\(profitText) (\(percentText)%)"
                changeLabel.textColor = Colors.positiveGrow
            } else if absoluteProfit < 0 {
                changeLabel.text = "↓ $\(profitText) (\(percentText)%)"
                changeLabel.textColor = Colors.negativeGrow
            }
        } else {
            changeLabel.text = ""
        }
    }
}
