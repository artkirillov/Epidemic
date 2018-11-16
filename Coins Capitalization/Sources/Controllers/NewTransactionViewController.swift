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
        case textField(title: String, placeholder: String, text: String?)
        case totalCost(title: String, value: String)
        case button(title: String)
        case dateTime(date: String, time: String)
        case notes(placeholder: String, text: String?)
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
        
        rows = makeRows(exchange: nil, market: nil, price: nil, quantity: nil, date: nil, notes: nil)
        
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
        tableView.register(UINib(nibName: NotesCell.identifier, bundle: nil), forCellReuseIdentifier: NotesCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        
        segmentedControl.items = [
            NSLocalizedString("Buy", comment: "").uppercased(),
            NSLocalizedString("Sell", comment: "").uppercased(),
            NSLocalizedString("Transfer", comment: "").uppercased()
        ]
        segmentedControl.thumb = .line
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlChanged(_ sender: SegmentedControl) {
        print("--- New segment \(sender.selectedIndex)")
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: - Private Properties
    
    private var transaction = Transaction(kind: Transaction.Kind.buy.rawValue)
    private var exchange: Exchange?
    private var market: Market?
    
    private let feedBackGenerator = UIImpactFeedbackGenerator()
    private var tableHeaderView: PortfolioTableHeaderView?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: SegmentedControl!
    @IBOutlet private var tableView: UITableView!
    
    private var lastContentOffset: CGFloat = 0.0
    private let contentOffsetThreshold: CGFloat = 37.0
    private let animation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = kCATransitionFade
        return animation
    }()
    
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
            
        case .textField(let title, let placeholder, let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell
                else { return UITableViewCell() }
            cell.configure(title: title, placeholder: placeholder, text: text, delegate: self)
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
            
        case .notes(let placeholder, let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesCell.identifier, for: indexPath) as? NotesCell
                else { return UITableViewCell() }
            cell.configure(placeholder: placeholder, text: text)
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension NewTransactionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case .option:
//            if let controller = storyboard?.instantiateViewController(withIdentifier: "CatalogViewController") as? CatalogViewController {
//                controller.delegate = self
//                controller.exchangeId = exchange?.exchangeId
//                controller.elements = indexPath.row == 0 ? .exchanges(exchanges: []) : .markets(markets: [])
//                present(controller, animated: true, completion: nil)
//            }
            let controller = PickerViewController(element: .date)
            controller.modalPresentationStyle = .overCurrentContext
            present(controller, animated: false, completion: nil)
            
        case .textField:
            guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
            cell.beginEdit()
            
        case .button, .totalCost, .dateTime, .notes: break
        }
    }
    
}

// MARK: - UIScrollViewDelegate

extension NewTransactionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y - contentOffsetThreshold) * (lastContentOffset - contentOffsetThreshold) <= 0 {
            titleLabel.layer.add(animation, forKey: kCATransition)
            
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
    
}

// MARK: - CatalogViewControllerDelegate

extension NewTransactionViewController: CatalogViewControllerDelegate {
    func catalogViewController(controller: CatalogViewController, didSelectExchange exchange: Exchange) {
        self.exchange = exchange
        rows = makeRows(exchange: exchange, market: nil, price: nil, quantity: nil, date: Date(), notes: nil)
        tableView.reloadData()
    }
    
    func catalogViewController(controller: CatalogViewController, didSelectMarket market: Market) {
        self.market = market
        rows = makeRows(exchange: exchange, market: market, price: market.priceQuote, quantity: nil, date: Date(), notes: nil)
        tableView.reloadData()
    }
}

// MARK: - TextFieldCellDelegate

extension NewTransactionViewController: TextFieldCellDelegate {
    
    func textFieldCell(cell: TextFieldCell, didChangeText text: String?) {
        print("--- new text \(text ?? "")")
    }
    
}

// MARK: - DateTimeCellDelegate

extension NewTransactionViewController: DateTimeCellDelegate {
    
    func dateTimeCellDidRequestNewDate(cell: DateTimeCell) {
        print("--- open date picker")
    }
    
    func dateTimeCellDidRequestNewTime(cell: DateTimeCell) {
        print("--- open time picker")
    }
    
}

// MARK: - ButtonCellDelegate

extension NewTransactionViewController: ButtonCellDelegate {
    
    func buttonCellDidTouched(cell: ButtonCell) {
        print("--- approve")
    }
    
}

// MARK: - Network Requests

private extension NewTransactionViewController {
    
    func makeRows(exchange: Exchange?, market: Market?, price: String?, quantity: String?, date: Date?, notes: String?) -> [Row] {
        
        var rows: [Row] = [.option(title: NSLocalizedString("Exchange", comment: ""), value: exchange?.name ?? "---")]
        
        if let _ = exchange, let market = market {
            rows += [
                .option(title: NSLocalizedString("Traiding pair", comment: ""), value: "\(market.baseSymbol)/\(market.quoteSymbol)"),
                .textField(title: NSLocalizedString("Price", comment: ""), placeholder: "---", text: market.priceQuote)
            ]
        } else {
            rows += [
                .option(title: NSLocalizedString("Traiding pair", comment: ""), value: "---"),
                .textField(title: NSLocalizedString("Price", comment: ""), placeholder: "---", text: price)
            ]
        }
        
        rows += [
            .textField(title: NSLocalizedString("Quantity", comment: ""), placeholder: "---", text: quantity),
            .totalCost(title: NSLocalizedString("Total cost", comment: ""), value: "---"),
            .dateTime(date: "01.01.2018", time: "12:12"),
            .notes(placeholder: "Notes", text: NSLocalizedString("Notes", comment: "")),
            .button(title: NSLocalizedString("Done", comment: ""))
        ]
        
        return rows
    }
    
}
