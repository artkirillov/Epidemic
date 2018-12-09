//
//  NewTransactionViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 26/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class NewTransactionViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Row {
        case option(title: String, value: String)
        case textField(type: TextFiledType, placeholder: String)
        case totalCost(title: String, value: String)
        case dateTime(date: String, time: String)
        case button(title: String)
    }
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: NewTransactionViewController.self)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var rows: [Row] = []
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = makeRows(exchange: nil, market: nil, price: nil, quantity: nil, fee: nil, date: date)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlChanged(_ sender: SegmentedControl) {
        print("--- New segment \(sender.selectedIndex)")
    }
    
    @objc func handleTap() {
        view.endEditing(true)
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
    
    private var transaction = Transaction(kind: Transaction.Kind.buy.rawValue)
    private var exchange: Exchange?
    private var market: Market?
    private var date = Date()
    private var quantity: Double?
    private var price: Double?
    private var fee: Double?
    
    private let feedBackGenerator = UIImpactFeedbackGenerator()
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
            
        case .button(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else { return UITableViewCell() }
            cell.configure(title: title, delegate: self)
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
                PickerViewController.Element.exchange :
                PickerViewController.Element.market(exchangeId: exchange?.exchangeId, baseSymbol: nil)
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
    
    func pickerViewController(controller: PickerViewController, didSelectExchange exchange: Exchange) {
        self.exchange = exchange
        market = nil
        price = nil
        quantity = nil
        fee = nil
        
        rows = makeRows(
            exchange: exchange,
            market: market,
            price: price,
            quantity: quantity,
            fee: fee,
            date: date
        )
        tableView.reloadData()
    }
    
    func pickerViewController(controller: PickerViewController, didSelectMarket market: Market) {
        self.market = market
        price = Double(market.priceQuote)
        quantity = nil
        fee = nil
        
        rows = makeRows(
            exchange: exchange,
            market: market,
            price: price,
            quantity: quantity,
            fee: fee,
            date: date
        )
        tableView.reloadData()
    }
    
    func pickerViewController(controller: PickerViewController, didSelectDate date: Date) {
        self.date = date
        
        rows = makeRows(
            exchange: exchange,
            market: market,
            price: price,
            quantity: quantity,
            fee: fee,
            date: date
        )
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
        case .price:    price = number
        case .quantity: quantity = number
        case .fee:      fee = number
        }
        
        rows = makeRows(
            exchange: exchange,
            market: market,
            price: price,
            quantity: quantity,
            fee: fee,
            date: date
        )
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
        print("--- SAVE TRANSACTION")
    }
    
}

// MARK: - Network Requests

private extension NewTransactionViewController {
    
    func makeRows(exchange: Exchange?, market: Market?, price: Double?, quantity: Double?, fee: Double?, date: Date) -> [Row] {
        
        var rows: [Row] = [.option(title: NSLocalizedString("Exchange", comment: ""), value: exchange?.name ?? "---")]
        
        if let market = market {
            rows += [.option(title: NSLocalizedString("Traiding pair", comment: ""), value: "\(market.baseSymbol)/\(market.quoteSymbol)")]
        } else {
            rows += [.option(title: NSLocalizedString("Traiding pair", comment: ""), value: "---")]
        }
        
        let (dateString, timeString) = dateTime(from: date)
        
        rows += [
            .textField(type: .price(market?.quoteSymbol, price), placeholder: "---"),
            .textField(type: .quantity(quantity), placeholder: "---"),
            .textField(type: .fee(market?.quoteSymbol, fee), placeholder: "---"),
            .dateTime(date: dateString, time: timeString)
        ]
        
        var valueText = "---"
        let value = (price ?? 0.0) * (quantity ?? 0.0) + (fee ?? 0.0)
        if value > 0, let market = market {
            let valueFormatted = Formatter.format(value, maximumFractionDigits: Formatter.maximumFractionDigits(for: value))
            valueText = valueFormatted.flatMap { "\($0) \(market.quoteSymbol)" } ?? "---"
        }
        
        rows += [
            .totalCost(title: NSLocalizedString("In total", comment: ""), value: valueText),
            .button(title: NSLocalizedString("Done", comment: ""))
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
