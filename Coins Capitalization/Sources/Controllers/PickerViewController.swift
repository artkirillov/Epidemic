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
    func pickerViewController(controller: PickerViewController, didSelectDate date: Date)
}

final class PickerViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Element {
        case dateTime(Date?, isDate: Bool)
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
        
        super.init(nibName: nil, bundle: nil)
        
        switch element {
        case .dateTime(let date, let isDate):
            setDatePicker(date: date, isDate: isDate)
            
        case .exchange, .market:
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
    
    private let element: Element
    private var picker = UIView()
    private let effectView = UIVisualEffectView()
    private let containerView = UIView()
    private let doneButton = UIButton(type: .system)
    
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
        case .exchanges(let exchanges):
            guard exchanges.count > 0 else { return }
            delegate?.pickerViewController(controller: self, didSelectExchange: exchanges[row])
            
        case .markets(let markets):
            guard markets.count > 0 else { return }
            delegate?.pickerViewController(controller: self, didSelectMarket: markets[row])
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
    
    func setDatePicker(date: Date?, isDate: Bool) {
        let picker = UIDatePicker()
        picker.datePickerMode = isDate ? .date : .time
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.setValue(Colors.majorTextColor, forKey: "textColor")
        date.flatMap { picker.setDate($0, animated: false) }
        self.picker = picker
    }
    
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
        doneButton.bottomAnchor.constraint(equalTo: picker.topAnchor, constant: Layout.smallMargin).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerView.transform = CGAffineTransform(translationX: 0.0, y: containerView.bounds.height)
    }
    
    @objc func handleTap() {
        dismissPicker(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped() {
        dismissPicker(animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ picker: UIDatePicker) {
        delegate?.pickerViewController(controller: self, didSelectDate: picker.date)
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
                    (slf.picker as? UIPickerView)?.reloadAllComponents()
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
                    (slf.picker as? UIPickerView)?.reloadAllComponents()
                },
                failure: { [weak self] error in
                    self?.showErrorAlert(error)
            })
            
            
        default: break
            
        }
    }
    
}
