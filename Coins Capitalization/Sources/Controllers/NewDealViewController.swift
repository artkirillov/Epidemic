//
//  NewDealViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 19.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol NewDealViewControllerDelegate: class {
    func newDealViewController(controller: NewDealViewController, didAdd asset: Asset)
}

final class NewDealViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: NewDealViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animation.duration = 0.2
        animation.type = kCATransitionFade
        
        cancelButton.layer.cornerRadius = 4.0
        
        doneButton.isEnabled = false
        doneButton.layer.cornerRadius = 4.0
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitleColor(.lightGray, for: .disabled)
        doneButton.backgroundColor = Colors.controlDisabled
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @objc func handleSwipe() {
        if amountTextField.isFirstResponder || costTextField.isFirstResponder {
            view.endEditing(true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func chooseButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let controller = storyboard.instantiateViewController(withIdentifier: "CoinsCatalogViewController") as? CoinsCatalogViewController {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        view.endEditing(true)
        
        guard let amountText = amountTextField.text, let costText = costTextField.text,
            let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
            let cost = Double(costText.replacingOccurrences(of: ",", with: ".")) else { return }
        asset.volume.append(Volume(amount: amount, price: cost / amount))
        
        delegate?.newDealViewController(controller: self, didAdd: asset)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private properties
    
    private var asset = Asset(name: "", symbol: "", volume: [], currentPrice: 0.0)
    private let animation = CATransition()
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet weak var amountTextFieldBottomLine: UIView!
    @IBOutlet weak var costTextFieldBottomLine: UIView!
}

// MARK: - CoinsCatalogViewControllerDelegate

extension NewDealViewController: CoinsCatalogViewControllerDelegate {
    
    func coinsCatalogViewController(controller: CoinsCatalogViewController, didSelect coin: Coin) {
        asset.name = coin.name
        asset.symbol = coin.symbol
        asset.currentPrice = Double(coin.priceUSD ?? "")
        chooseButton.layer.add(animation, forKey: kCATransition)
        chooseButton.setTitle("\(asset.symbol) \(asset.name)", for: .normal)
        chooseButton.setTitleColor(.white, for: .normal)
    }
}

// MARK: - UITextFieldDelegate

extension NewDealViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === amountTextField {
            amountTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            amountTextFieldBottomLine.backgroundColor = .white
        } else {
            costTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            costTextFieldBottomLine.backgroundColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === amountTextField {
            amountTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            amountTextFieldBottomLine.backgroundColor = Colors.controlEnabled
        } else {
            costTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
            costTextFieldBottomLine.backgroundColor = Colors.controlEnabled
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text == "", string == "," {
            textField.text = "0"
        }
        
        let secondTextField = textField === amountTextField ? costTextField : amountTextField
        
        if let text1 = textField.text, let text2 = secondTextField?.text,
            let number1 = Double((string.isEmpty ? String(text1.dropLast()) : text1 + string).replacingOccurrences(of: ",", with: ".")),
            let number2 = Double(text2.replacingOccurrences(of: ",", with: ".")),
            number1 > 0, number2 > 0, !asset.symbol.isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = Colors.controlEnabled
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = Colors.controlDisabled
        }
        return true
    }
}
