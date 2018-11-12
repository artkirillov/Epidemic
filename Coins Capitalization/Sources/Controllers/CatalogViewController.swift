//
//  CatalogViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol CatalogViewControllerDelegate: class {
    func catalogViewController(controller: CatalogViewController, didSelectExchange exchange: Exchange)
    func catalogViewController(controller: CatalogViewController, didSelectMarket market: Market)
}

final class CatalogViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Elements {
        case exchanges(exchanges: [Exchange])
        case markets(markets: [Market])
    }
    
    // MARK: - Public Properties
    
    weak var delegate: CatalogViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var elements: Elements = .exchanges(exchanges: [])
    var exchangeId: String?
    var baseSymbol: String?
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = NSLocalizedString("Catalog", comment: "").uppercased()
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        let placeholderString = NSLocalizedString("Search", comment: "")
        searchTextField.attributedPlaceholder = NSAttributedString.attributedTextFieldPlaceholder(string: placeholderString)
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 16)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearSearchTextField), for: .touchUpInside)
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.isHidden = true
        searchTextFieldClearButton = clearButton
        searchTextFieldClearButton?.isHidden = true
        
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        
        requestData()
    }
    
    @objc func clearSearchTextField() {
        searchTextField.text = nil
        searchTextFieldClearButton?.isHidden = true
        filteredItems = items
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    
    private var searchTextFieldClearButton: UIButton?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var items: [String] = []
    private var filteredItems: [String] = [] {
        didSet {
            let image = UIImage(imageLiteralResourceName: "noSearchResults")
            let title = NSLocalizedString("Empty search results title", comment: "")
            let message = NSLocalizedString("Empty search results message", comment: "")
            tableView.backgroundView = filteredItems.isEmpty ? MessageView(image: image, title: title, message: message) : nil
            tableView.reloadData()
        }
    }
    
    private let animation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = kCATransitionFade
        return animation
    }()
    
}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogItemTableViewCell", for: indexPath) as! CatalogItemTableViewCell
        let item = filteredItems[indexPath.row]
        cell.configure(title: item)
        return cell
    }
}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
        let index = indexPath.row
        switch elements {
        case .exchanges(let exchanges):
            delegate?.catalogViewController(controller: self, didSelectExchange: exchanges[index])
        case .markets(let markets):
            delegate?.catalogViewController(controller: self, didSelectMarket: markets[index])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate

extension CatalogViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else {
            self.filteredItems = self.items
            return true
        }
        
        updateItems(withSearchText: string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextFieldClearButton?.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextFieldClearButton?.isHidden = textField.text?.isEmpty ?? true
    }
    
    private func update() {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            updateItems(withSearchText: searchText)
        } else {
            filteredItems = items
        }
    }
    
    private func updateItems(withSearchText searchText: String) {
        filteredItems = items.filter { $0.lowercased().range(of: searchText.lowercased()) != nil }
    }
    
}

// MARK: - Network Requests

private extension CatalogViewController {
    
    func requestData() {
        switch elements {
        case .exchanges:
            API.requestExchanges(
                success: { [weak self] response in
                    guard let slf = self else { return }
                    slf.stopAnimateActivity()
                    
                    let exchanges = response.data.sorted { $0.name < $1.name }
                    slf.elements = .exchanges(exchanges: exchanges)
                    slf.items = exchanges.map { $0.name }
                    slf.update()
                },
                failure: { [weak self] error in
                    self?.stopAnimateActivity()
                    self?.showErrorAlert(error)
            })
        case .markets:
            API.requestMarkets(
                exchangeId: exchangeId,
                baseSymbol: baseSymbol,
                success: { [weak self] response in
                    guard let slf = self else { return }
                    slf.stopAnimateActivity()
                    
                    let markets = response.data.sorted { "\($0.baseSymbol)/\($0.quoteSymbol)" < "\($1.baseSymbol)/\($1.quoteSymbol)" }
                    slf.elements = .markets(markets: markets)
                    slf.items = markets.map { "\($0.baseSymbol)/\($0.quoteSymbol)" }
                    slf.update()
                },
                failure: { [weak self] error in
                    self?.stopAnimateActivity()
                    self?.showErrorAlert(error)
            })
        }
    }
    
}

private extension CatalogViewController {
    
    func stopAnimateActivity() {
        DispatchQueue.main.async { [weak self] in
            guard let slf = self else { return }
            
            slf.activityIndicator?.stopAnimating()
            
            slf.searchTextField.layer.add(slf.animation, forKey: kCATransition)
            slf.searchTextField.isHidden = false
        }
    }
}
