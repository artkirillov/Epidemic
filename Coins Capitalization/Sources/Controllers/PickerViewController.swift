//
//  PickerViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 12/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol PickerViewControllerDelegate: class {
    func pickerViewController(controller: PickerViewController, didSelectExchange exchange: Exchange)
    func pickerViewController(controller: PickerViewController, didSelectMarket market: Market)
}

final class PickerViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Element {
        case date
        case time
        case exchange
        case market(exchangeId: String?, baseSymbol: String?)
    }
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: PickerViewController.self)
    
    weak var delegate: PickerViewControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Constructors
    
    init(element: Element) {
        
        self.element = element
        
        switch element {
        case .date:     picker = UIPickerView()
        case .time:     picker = UIPickerView()
        case .exchange: picker = UIPickerView()
        case .market:   picker = UIPickerView()
        }
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupConstraints()
        requestData()
        
        picker.dataSource = self
        picker.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
        containerView.alpha = 1.0
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { self.containerView.transform = CGAffineTransform.identity },
            completion: nil)
    }
    
    
    // MARK: - Private Properties
    
    private var items: Items = .exchanges([])
    
    private let element: Element
    private let picker: UIPickerView
    private let effectView = UIVisualEffectView()
    private let containerView = UIView()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
}

// MARK: - UIPickerViewDataSource

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.rows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(
            string: items.rows[row],
            attributes: [
                .font: Fonts.title,
                .foregroundColor: Colors.majorTextColor]
        )
    }
    
}

// MARK: - UIPickerViewDelegate

extension PickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch items {
        case .exchanges(let exchanges): delegate?.pickerViewController(controller: self, didSelectExchange: exchanges[row])
        case .markets(let markets): delegate?.pickerViewController(controller: self, didSelectMarket: markets[row])
        }
    }
    
}

private extension PickerViewController {
    
    // MARK: - Private Nested
    
    enum Items {
        case exchanges([Exchange])
        case markets([Market])
        
        var rows: [String] {
            switch self {
            case .exchanges(let exchanges): return exchanges.map { $0.name }
            case .markets(let markets):     return markets.map { "\($0.baseSymbol)/\($0.quoteSymbol)" }
            }
        }
    }
    
    // MARK: - Private Methods
    
    func setupViews() {
        
        view.backgroundColor = .clear
        
        view.addSubview(containerView)
        containerView.alpha = 0.0
        
        containerView.addSubview(effectView)
        effectView.effect = UIBlurEffect(style: .dark)
        
        containerView.addSubview(cancelButton)
        containerView.addSubview(doneButton)
        containerView.addSubview(picker)
        
        picker.tintColor = Colors.majorTextColor
        picker.backgroundColor = .clear
        picker.tintColor = .white
        
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(Colors.majorTextColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneButton.setTitleColor(Colors.majorTextColor, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        effectView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        effectView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
    }
    
    @objc func cancelButtonTapped() {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { self.containerView.transform = CGAffineTransform(translationX: 0.0, y: self.containerView.bounds.height) },
            completion: { _ in self.dismiss(animated: false, completion: nil) })
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Network Requests

private extension PickerViewController {
    
    func requestData() {
        switch element {
        case .exchange:
            
            API.requestExchanges(
                success: { [weak self] response in
                    guard let slf = self else { return }
                    
                    let exchanges = response.data.sorted { $0.name < $1.name }
                    slf.items = .exchanges(exchanges)
                    slf.picker.reloadAllComponents()
                },
                failure: { [weak self] error in self?.showErrorAlert(error) }
            )
        
        case .market(let exchangeId, let baseSymbol):
            
            API.requestMarkets(
                exchangeId: exchangeId,
                baseSymbol: baseSymbol,
                success: { [weak self] response in
                    guard let slf = self else { return }
                    
                    let markets = response.data.sorted { "\($0.baseSymbol)/\($0.quoteSymbol)" < "\($1.baseSymbol)/\($1.quoteSymbol)" }
                    slf.items = .markets(markets)
                    slf.picker.reloadAllComponents()
                },
                failure: { [weak self] error in
                    self?.showErrorAlert(error)
            })
            
            
        default: break
            
        }
    }
    
}
