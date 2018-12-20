//
//  NewTransactionViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 26/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol NewTransactionViewControllerDelegate: class {
    func newTransactionViewControllerDidEndEditing(controller: NewTransactionViewController)
}

final class NewTransactionViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Row {
        case option(title: String, value: String)
        case textField(type: TextFiledType, placeholder: String)
        case totalCost(title: String, value: String)
        case dateTime(date: String, time: String)
        case button(title: String, isEnabled: Bool)
    }
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: NewTransactionViewController.self)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var delegate: NewTransactionViewControllerDelegate?
    var coin: Coin?
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = makeRows()
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = NSLocalizedString("New Transaction", comment: "").uppercased()
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: 30.0))
        tableView.register(UINib(nibName: OptionCell.identifier, bundle: nil), forCellReuseIdentifier: OptionCell.identifier)
        tableView.register(UINib(nibName: TextFieldCell.identifier, bundle: nil), forCellReuseIdentifier: TextFieldCell.identifier)
        tableView.register(UINib(nibName: ButtonCell.identifier, bundle: nil), forCellReuseIdentifier: ButtonCell.identifier)
        tableView.register(UINib(nibName: TotalCostCell.identifier, bundle: nil), forCellReuseIdentifier: TotalCostCell.identifier)
        tableView.register(UINib(nibName: DateTimeCell.identifier, bundle: nil), forCellReuseIdentifier: DateTimeCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150.0
        
        segmentedControl.items = [
            NSLocalizedString("Buy", comment: "").uppercased(),
            NSLocalizedString("Sell", comment: "").uppercased(),
            NSLocalizedString("Transfer", comment: "").uppercased()
        ]
        segmentedControl.thumb = .line
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK: - Private Properties
    
    private var rows: [Row] = []
    private var exchange: Exchange?
    private var market: Market?
    private var quantity: Double?
    private var price: Double?
    private var priceUSD: Double?
    private var fee: Double?
    private var date = Date()
    private var buttonEnabled: Bool {
        return exchange != nil && market != nil && quantity != nil && price != nil
    }
    
    private var tableHeaderView: PortfolioTableHeaderView?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: SegmentedControl!
    @IBOutlet private var tableView: UITableView!
    
    private var keyboardHeight: CGFloat = 0.0
    
}

// MARK: - UITableViewDataSource

extension NewTransactionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .option(let title, let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.identifier, for: indexPath) as? OptionCell
                else { return UITableViewCell() }
            cell.configure(title: title, value: value)
            return cell
            
        case .textField(let type, let placeholder):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell
                else { return UITableViewCell() }
            cell.configure(type: type, placeholder: placeholder, delegate: self)
            return cell
            
        case .button(let title, let isEnabled):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else { return UITableViewCell() }
            cell.configure(title: title, isEnabled: isEnabled, delegate: self)
            return cell
            
        case .totalCost(let title, let value):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalCostCell.identifier, for: indexPath) as? TotalCostCell
                else { return UITableViewCell() }
            cell.configure(title: title, value: value)
            return cell
        
        case .dateTime(let date, let time):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DateTimeCell.identifier, for: indexPath) as? DateTimeCell
                else { return UITableViewCell() }
            cell.configure(datetitle: date, timeTitle: time, delegate: self)
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension NewTransactionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.endEditing(true)
        
        switch rows[indexPath.row] {
        case .option:
            let element = indexPath.row == 0 ?
                PickerViewController.Element.coin : indexPath.row == 1 ?
                    PickerViewController.Element.exchange :
                PickerViewController.Element.market(exchangeId: exchange?.id, baseSymbol: coin?.short)
            let controller = PickerViewController(element: element)
            controller.delegate = self
            controller.modalPresentationStyle = .overCurrentContext
            present(controller, animated: false, completion: nil)
            
        case .textField:
            guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
            cell.beginEdit()
            
        case .button, .totalCost, .dateTime: break
        }
    }
    
}

// MARK: - CatalogViewControllerDelegate

extension NewTransactionViewController: PickerViewControllerDelegate {
    func pickerViewController(controller: PickerViewController, didSelectCoin coin: Coin) {
        self.coin = coin
        market = nil
        
        rows = makeRows()
        tableView.reloadData()
    }
    
    
    func pickerViewController(controller: PickerViewController, didSelectExchange exchange: Exchange) {
        if self.exchange != nil || !exchange.id.isEmpty {
            market = nil
            price = nil
            quantity = nil
            fee = nil
        }
        
        self.exchange = exchange
        rows = makeRows()
        tableView.reloadData()
    }
    
    func pickerViewController(controller: PickerViewController, didSelectMarket market: Market) {
        self.market = market
        price = Double(market.priceQuote)
        priceUSD = Double(market.priceUsd)
        quantity = nil
        fee = nil
        
        rows = makeRows()
        tableView.reloadData()
    }
    
    func pickerViewController(controller: PickerViewController, didSelectDate date: Date) {
        self.date = date
        
        rows = makeRows()
        tableView.reloadData()
    }
    
}

// MARK: - TextFieldCellDelegate

extension NewTransactionViewController: TextFieldCellDelegate {
    
    func textFieldCellDoneButtonTapped(cell: TextFieldCell) {
        view.endEditing(true)
    }
    
    func textFieldCell(type: TextFiledType, didChangeText text: String?) {
        let numberText = text?.replacingOccurrences(of: ",", with: ".")
        let number = numberText.flatMap { Double($0) }
        
        switch type {
        case .price:
            price = number
            priceUSD = (exchange?.id.isEmpty ?? true) && (market?.quoteSymbol ?? "") == "USD" ? number : nil
        case .quantity: quantity = number
        case .fee:      fee = number
        }
        
        rows = makeRows()
        tableView.reloadData()
    }
    
}

// MARK: - DateTimeCellDelegate

extension NewTransactionViewController: DateTimeCellDelegate {
    
    func dateTimeCellDidRequestNewDate(cell: DateTimeCell) {
        let controller = PickerViewController(element: .dateTime(date, isDate: true))
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: false, completion: nil)
    }
    
    func dateTimeCellDidRequestNewTime(cell: DateTimeCell) {
        let controller = PickerViewController(element: .dateTime(date, isDate: false))
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: false, completion: nil)
    }
    
}

// MARK: - ButtonCellDelegate

extension NewTransactionViewController: ButtonCellDelegate {
    
    func buttonCellDidTouched(cell: ButtonCell) {
        
        let kind: Transaction.Kind
        switch segmentedControl.selectedIndex {
        case 0: kind = .buy
        case 1: kind = .sell
        default: kind = .transfer
        }
        
        if let market = market, let price = price, let priceUSD = priceUSD, let quantity = quantity {
            let transaction = Transaction(
                kind: kind,
                exchange: exchange,
                baseSymbol: market.baseSymbol,
                quoteSymbol: market.quoteSymbol,
                price: price,
                priceUsd: priceUSD,
                quantity: quantity,
                fee: fee ?? 0.0,
                date: date)
            
            let makeTransaction = { [weak self] in
                var transactions = Storage.transactions() ?? []
                transactions.append(transaction)
                Storage.save(transactions: transactions)
                
                guard let slf =  self else { return }
                slf.delegate?.newTransactionViewControllerDidEndEditing(controller: slf)
                slf.dismiss(animated: true, completion: nil)
            }
            
            var assets = Storage.assets() ?? []
            
            switch kind {
            case .buy:
                let volume = Volume(amount: quantity, price: priceUSD)
                if let index = assets.index(where: { $0.symbol == market.baseSymbol }) {
                    assets[index].volume.append(volume)
                } else {
                    let coins = Storage.coins() ?? []
                    let name = coins.first(where: { $0.short == market.baseSymbol })?.long ?? market.baseSymbol
                    assets.append(Asset(name: name, symbol: market.baseSymbol, volume: [volume], currentPrice: price))
                }
                Storage.save(assets: assets)
                makeTransaction()
                
            case .sell:
                var newVolume: [Volume] = []
                
                if let index = assets.index(where: { $0.symbol == market.baseSymbol }), assets[index].totalAmount >= quantity  {
                    
                    let totalAmount = assets[index].totalAmount
                    assets[index].volume.forEach {
                        newVolume.append(Volume(amount: $0.amount - quantity * $0.amount / totalAmount, price: $0.price))
                    }
                    assets[index].volume = newVolume
                    
                    if assets[index].totalAmount < 10e-10 { assets.remove(at: index) }
                    Storage.save(assets: assets)
                    makeTransaction()
                } else {
                    showErrorAlert(
                        title: NSLocalizedString("Not enough title", comment: ""),
                        message: NSLocalizedString("Not enough message", comment: "")
                    )
                }
                
            case .transfer:
                guard let exchangeId = exchange?.id, !exchangeId.isEmpty else {
                    showErrorAlert(
                        title: NSLocalizedString("Exchange required title", comment: ""),
                        message: NSLocalizedString("Exchange required message", comment: "")
                    )
                    return
                }
                
                var newVolume: [Volume] = []
                
                if let index = assets.index(where: { $0.symbol == market.baseSymbol }), assets[index].totalAmount >= quantity  {
                    let totalAmount = assets[index].totalAmount
                    assets[index].volume.forEach {
                        newVolume.append(Volume(amount: $0.amount - quantity * $0.amount / totalAmount, price: $0.price))
                    }
                    assets[index].volume = newVolume
                    
                    if assets[index].totalAmount < 10e-10 { assets.remove(at: index) }
                    Storage.save(assets: assets)
                    
                    let volume = Volume(amount: price * quantity + (fee ?? 0.0), price: priceUSD)
                    if let index = assets.index(where: { $0.symbol == market.quoteSymbol }) {
                        assets[index].volume.append(volume)
                    } else {
                        let coins = Storage.coins() ?? []
                        let name = coins.first(where: { $0.short == market.quoteSymbol })?.long ?? market.quoteSymbol
                        assets.append(Asset(name: name, symbol: market.quoteSymbol, volume: [volume], currentPrice: price))
                    }
                    Storage.save(assets: assets)
                    makeTransaction()
                } else {
                    showErrorAlert(
                        title: NSLocalizedString("Not enough title", comment: ""),
                        message: NSLocalizedString("Not enough message", comment: "")
                    )
                }
            }
        }
    }
    
}

// MARK: - Network Requests

private extension NewTransactionViewController {
    
    func makeRows() -> [Row] {
        let defaultPlaceholder = "---"
        
        var rows: [Row] = [
            .option(title: NSLocalizedString("Coin", comment: ""), value: coin?.short ?? defaultPlaceholder),
            .option(title: NSLocalizedString("Exchange", comment: ""), value: exchange?.name ?? defaultPlaceholder),
            .option(title: NSLocalizedString("Traiding pair", comment: ""), value: market?.quoteSymbol ?? defaultPlaceholder)
        ]
        
        let (dateString, timeString) = dateTime(from: date)
        
        rows += [
            .textField(type: .price(market?.quoteSymbol, price), placeholder: defaultPlaceholder),
            .textField(type: .quantity(quantity), placeholder: defaultPlaceholder),
            .textField(type: .fee(market?.quoteSymbol, fee), placeholder: defaultPlaceholder),
            .dateTime(date: dateString, time: timeString)
        ]
        
        var valueText = defaultPlaceholder
        let value = (price ?? 0.0) * (quantity ?? 0.0) + (fee ?? 0.0)
        if value > 0, let market = market {
            let valueFormatted = Formatter.format(value, maximumFractionDigits: Formatter.maximumFractionDigits(for: value))
            valueText = valueFormatted.flatMap { "\($0) \(market.quoteSymbol)" } ?? defaultPlaceholder
        }
        
        rows += [
            .totalCost(title: NSLocalizedString("In total", comment: ""), value: valueText),
            .button(title: NSLocalizedString("Done", comment: ""), isEnabled: buttonEnabled)
        ]
        
        return rows
    }
    
    func dateTime(from date: Date) -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateString = dateFormatter.string(from: date)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: date)
        
        return (dateString, timeString)
    }
    
}
