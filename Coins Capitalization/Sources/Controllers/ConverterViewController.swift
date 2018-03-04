//
//  ConverterViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class ConverterViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Side {
        case left
        case right
    }
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coins = Storage.coins(), coins.count > 1 {
            leftCoin = coins[0]
            rightCoin = coins[1]
        }
        leftButton.setTitle(leftCoin?.symbol, for: .normal)
        rightButton.setTitle(rightCoin?.symbol, for: .normal)
        leftCoinAmount = 1.0
        convert(side: .right)
        
        animation.duration = 0.2
        animation.type = kCATransitionFade
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleTap))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        handleButtonTap(.left)
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        handleButtonTap(.right)
    }
    
    func handleButtonTap(_ side: Side) {
        self.side = side
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let controller = storyboard.instantiateViewController(withIdentifier: "CoinsCatalogViewController") as? CoinsCatalogViewController {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private properties
    
    private let animation = CATransition()
    private var side = Side.left
    private var leftCoin: Coin?
    private var rightCoin: Coin?
    private var leftCoinAmount = 0.0
    private var rightCoinAmount = 0.0
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftTextField: UITextField!
    @IBOutlet weak var rightTextField: UITextField!
    @IBOutlet weak var leftTextFieldBottomLine: UIView!
    @IBOutlet weak var rightTextFieldBottomLine: UIView!
}

// MARK: - CoinsCatalogViewControllerDelegate

extension ConverterViewController: CoinsCatalogViewControllerDelegate {
    
    func coinsCatalogViewController(controller: CoinsCatalogViewController, didSelect coin: Coin) {
        switch side {
        case .left:
            leftCoin = coin
            leftButton.setTitle(coin.symbol, for: .normal)
        case .right:
            rightCoin = coin
            rightButton.setTitle(coin.symbol, for: .normal)
        }
        convert(side: side)
    }
}

// MARK: - UITextFieldDelegate

extension ConverterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === leftTextField {
            leftTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            leftTextFieldBottomLine.backgroundColor = .white
        } else {
            rightTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            rightTextFieldBottomLine.backgroundColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === leftTextField {
            leftTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            leftTextFieldBottomLine.backgroundColor = Colors.controlEnabled
        } else {
            rightTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            rightTextFieldBottomLine.backgroundColor = Colors.controlEnabled
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text == "", string == "," {
            textField.text = "0"
        }
        
        let secondTextField = textField === leftTextField ? rightTextField : leftTextField
        side = textField === leftTextField ? .right : .left
        
        if let text = textField.text,
            let number = Double((string.isEmpty ? String(text.dropLast()) : text + string).replacingOccurrences(of: ",", with: ".")),
            number > 0 {
            
            switch side {
            case .left:  rightCoinAmount = number
            case .right: leftCoinAmount = number
            }
            convert(side: side)
        } else {
            secondTextField?.text = nil
        }
        return true
    }
}

// MARK: - Converting

private extension ConverterViewController {
    
    func convert(side: Side) {
        guard let leftCoin = leftCoin, let rightCoin = rightCoin,
            let leftCoinPrice = Double(leftCoin.priceUSD ?? ""),
            let rightCoinPrice = Double(rightCoin.priceUSD ?? "") else { return }
        
        switch side {
        case .left:
            leftCoinAmount = rightCoinAmount * rightCoinPrice / leftCoinPrice
            setNumber(textField: leftTextField, value: leftCoinAmount)
        case .right:
            rightCoinAmount = leftCoinAmount * leftCoinPrice / rightCoinPrice
            setNumber(textField: rightTextField, value: rightCoinAmount)
        }
    }
    
    func setNumber(textField: UITextField, value: Double, maximumFractionDigits: Int = 6) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        guard let text = numberFormatter.string(from: value as NSNumber) else {
            textField.text = nil
            return
        }
        
        textField.text = text
    }
}