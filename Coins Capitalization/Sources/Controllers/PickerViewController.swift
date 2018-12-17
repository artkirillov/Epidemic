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
    func pickerViewController(controller: PickerViewController, didSelectCoin coin: Coin)
    func pickerViewController(controller: PickerViewController, didSelectDate date: Date)
}

final class PickerViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Element {
        case coin
        case exchange
        case market(exchangeId: String?, baseSymbol: String?)
        case dateTime(Date?, isDate: Bool)
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
        
        super.init(nibName: nil, bundle: nil)
        
        switch element {
        case .dateTime(let date, let isDate):
            let picker = UIDatePicker()
            picker.datePickerMode = isDate ? .date : .time
            picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            picker.setValue(Colors.majorTextColor, forKey: "textColor")
            date.flatMap { picker.setDate($0, animated: false) }
            self.picker = picker
            
        case .exchange, .market, .coin:
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            self.picker = picker
        }
        
        setupViews()
        setupConstraints()
        requestData()
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
    private var didSelectItem = false
    
    private let element: Element
    private var picker = UIView()
    private let effectView = UIVisualEffectView()
    private let containerView = UIView()
    private let doneButton = UIButton(type: .system)
    private let noDataBackground = UIView()
    private let noDataLabel = UILabel()
    
}

// MARK: - UIPickerViewDataSource

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.rows.count
    }
    
}

// MARK: - UIPickerViewDelegate

extension PickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickItem(inRow: row)
        didSelectItem = true
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

private extension PickerViewController {
    
    // MARK: - Private Nested
    
    enum Items {
        case coins([Coin])
        case exchanges([Exchange])
        case markets([Market])
        
        var rows: [String] {
            switch self {
            case .coins(let coins): return coins.map { $0.short }
            case .exchanges(let exchanges): return exchanges.map { $0.name }
            case .markets(let markets):     return markets.map { $0.quoteSymbol }
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
        
        containerView.addSubview(picker)
        containerView.addSubview(doneButton)
        
        picker.tintColor = Colors.majorTextColor
        picker.backgroundColor = .clear
        picker.tintColor = .white
        
        containerView.addSubview(noDataBackground)
        noDataBackground.addSubview(noDataLabel)
        
        noDataBackground.backgroundColor = Colors.cellBackgroundColor
        noDataBackground.layer.cornerRadius = 14.0
        noDataBackground.isHidden = true
        
        noDataLabel.textColor = Colors.minorTextColor
        noDataLabel.font = Fonts.subtitle
        noDataLabel.textAlignment = .center
        noDataLabel.text = NSLocalizedString("No data available", comment: "")
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)
        doneButton.layer.cornerRadius = Layout.buttonHeight / 2
        doneButton.backgroundColor = Colors.blueColor
        doneButton.setTitleColor(Colors.minorTextColor, for: .highlighted)
        doneButton.setTitleColor(Colors.majorTextColor, for: .normal)
        doneButton.titleLabel?.font = Fonts.buttonTitle
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
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
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.smallMargin).isActive = true
        doneButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Layout.bigMargin).isActive = true
        doneButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Layout.bigMargin).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
        
        noDataBackground.translatesAutoresizingMaskIntoConstraints = false
        noDataBackground.centerYAnchor.constraint(equalTo: picker.centerYAnchor).isActive = true
        noDataBackground.centerXAnchor.constraint(equalTo: picker.centerXAnchor).isActive = true
        
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.topAnchor.constraint(equalTo: noDataBackground.topAnchor, constant: 7.0).isActive = true
        noDataLabel.bottomAnchor.constraint(equalTo: noDataBackground.bottomAnchor, constant: -7.0).isActive = true
        noDataLabel.leadingAnchor.constraint(equalTo: noDataBackground.leadingAnchor, constant: 20.0).isActive = true
        noDataLabel.trailingAnchor.constraint(equalTo: noDataBackground.trailingAnchor, constant: -20.0).isActive = true
    }
    
    @objc func handleTap() {
        dismissPicker(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        if !didSelectItem, picker is UIPickerView { pickItem(inRow: 0) }
        dismissPicker(animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ picker: UIDatePicker) {
        delegate?.pickerViewController(controller: self, didSelectDate: picker.date)
        didSelectItem = true
    }
    
}

private extension PickerViewController {
    
    // MARK: - Private Nested
    
    struct Layout {
        static let buttonHeight: CGFloat = 44.0
        static let smallMargin: CGFloat = 8.0
        static let bigMargin: CGFloat = 50.0
        static let margin: CGFloat = 20.0
    }
    
    // MARK: - Private Methods
    
    func dismissPicker(animated: Bool, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: { self.containerView.transform = CGAffineTransform(translationX: 0.0, y: self.containerView.bounds.height) },
            completion: { _ in self.dismiss(animated: false, completion: nil) })
    }
    
    func pickItem(inRow row: Int) {
        switch items {
        case .coins(let coins):
            guard coins.count > 0 else { return }
            delegate?.pickerViewController(controller: self, didSelectCoin: coins[row])
            
        case .exchanges(let exchanges):
            guard exchanges.count > 0 else { return }
            delegate?.pickerViewController(controller: self, didSelectExchange: exchanges[row])
            
        case .markets(let markets):
            guard markets.count > 0 else { return }
            delegate?.pickerViewController(controller: self, didSelectMarket: markets[row])
        }
    }
    
}


// MARK: - Network Requests

private extension PickerViewController {
    
    func requestData() {
        switch element {
        case .coin:
            let coins = (Storage.coins() ?? []).sorted { $0.short < $1.short }
            items = .coins(coins)
            (picker as? UIPickerView)?.reloadAllComponents()
            
        case .exchange:
            
            API.requestExchanges(
                success: { [weak self] response in
                    guard let slf = self else { return }
                    
                    var exchanges = response.data.sorted { $0.name < $1.name }
                    exchanges.insert(Exchange(id: "", name: "No exchange"), at: 0)
                    slf.items = .exchanges(exchanges)
                    (slf.picker as? UIPickerView)?.reloadAllComponents()
                },
                failure: { [weak self] error in self?.noDataBackground.isHidden = false }
            )
        
        case .market(let exchangeId, let baseSymbol):
            if let exchangeId = exchangeId, !exchangeId.isEmpty {
                API.requestMarkets(
                    exchangeId: exchangeId,
                    baseSymbol: baseSymbol,
                    success: { [weak self] response in
                        guard let slf = self else { return }
                        
                        let markets = response.data.sorted { $0.quoteSymbol < $1.quoteSymbol }
                        slf.items = .markets(markets)
                        (slf.picker as? UIPickerView)?.reloadAllComponents()
                        slf.noDataBackground.isHidden = !markets.isEmpty
                    },
                    failure: { [weak self] error in self?.noDataBackground.isHidden = false
                })
            } else {
                let market = Market(
                    exchangeId: "",
                    baseSymbol: baseSymbol ?? "",
                    baseId: baseSymbol ?? "",
                    quoteSymbol: "USD",
                    quoteId: "USD",
                    priceQuote: "",
                    priceUsd: ""
                )
                
                items = .markets([market])
                (picker as? UIPickerView)?.reloadAllComponents()
                noDataBackground.isHidden = true
            }
            
        default: break
            
        }
    }
    
}
