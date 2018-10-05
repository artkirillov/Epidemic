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
        
        leftCoinAmount = 1.0
        convert(side: .right)
        
        view.backgroundColor = Colors.backgroundColor
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: NSLocalizedString("Converter", comment: "").uppercased())
        
        leftButton.setTitle(leftCoin?.symbol, for: .normal)
        leftButton.setTitleColor(Colors.lightBlueColor, for: .normal)
        leftButton.titleLabel?.font = Fonts.title
        
        rightButton.setTitle(rightCoin?.symbol, for: .normal)
        rightButton.setTitleColor(Colors.lightBlueColor, for: .normal)
        rightButton.titleLabel?.font = Fonts.title
        
        leftTextField.font = Fonts.title
        rightTextField.font = Fonts.title
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
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
    
    private let numberFormatter = NumberFormatter()
    private var side = Side.left
    private var leftCoin: Coin?
    private var rightCoin: Coin?
    private var leftCoinAmount = 0.0
    private var rightCoinAmount = 0.0
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var leftButton: UIButton!
    @IBOutlet private var rightButton: UIButton!
    @IBOutlet private var leftTextField: UITextField!
    @IBOutlet private var rightTextField: UITextField!
    
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
        numberFormatter.numberStyle = .decimal
        if let text = textField.text, let value = numberFormatter.number(from: text) as? Double {
            setNumber(textField: textField, value: value, style: .none)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        numberFormatter.numberStyle = .none
        if let text = textField.text, let value = numberFormatter.number(from: text) as? Double {
            setNumber(textField: textField, value: value, style: .decimal)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text == "", string == "," {
            textField.text = "0"
        }
        
        let secondTextField = textField === leftTextField ? rightTextField : leftTextField
        side = textField === leftTextField ? .right : .left
        
        if let text = textField.text,
            let number = numberFormatter.number(from: (string.isEmpty ? String(text.dropLast()) : text + string)) as? Double,
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
    
    func setNumber(textField: UITextField, value: Double, maximumFractionDigits: Int = 6, style: NumberFormatter.Style = .decimal) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = style
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        guard let text = numberFormatter.string(from: value as NSNumber) else {
            textField.text = nil
            return
        }
        
        textField.text = text
    }
}
