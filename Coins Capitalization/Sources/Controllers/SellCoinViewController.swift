//
//  SellCoinViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol SellCoinViewControllerDelegate: class {
    func sellCoinViewController(controller: SellCoinViewController, didChange asset: Asset)
}

final class SellCoinViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var asset: Asset?
    weak var delegate: SellCoinViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalAmount = asset?.totalAmount ?? 0.0
        assetLabel.text = "\(asset?.symbol ?? "") \(asset?.name ?? "")"
        
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
        if amountTextField.isFirstResponder {
            view.endEditing(true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        view.endEditing(true)
        
        guard var asset = asset, let amountText = amountTextField.text,
            let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }
        
        var newVolume: [Volume] = []
        asset.volume.forEach { newVolume.append(Volume(amount: $0.amount - amount * $0.amount / totalAmount, price: $0.price)) }
        asset.volume = newVolume
        delegate?.sellCoinViewController(controller: self, didChange: asset)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private properties
    
    private var totalAmount: Double = 0.0
    private let animation = CATransition()
    
    @IBOutlet weak var assetLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet weak var amountTextFieldBottomLine: UIView!
}

// MARK: - UITextFieldDelegate

extension SellCoinViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
        amountTextFieldBottomLine.backgroundColor = .white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        amountTextFieldBottomLine.layer.add(animation, forKey: kCATransition)
        amountTextFieldBottomLine.backgroundColor = Colors.controlEnabled
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text == "", string == "," {
            textField.text = "0"
        }
        
        if let text = textField.text,
            let amount = Double((string.isEmpty ? String(text.dropLast()) : text + string).replacingOccurrences(of: ",", with: ".")),
            amount > 0, amount <= totalAmount {
            doneButton.isEnabled = true
            doneButton.backgroundColor = Colors.controlEnabled
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = Colors.controlDisabled
        }
        return true
    }
}

