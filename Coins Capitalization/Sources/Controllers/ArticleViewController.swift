//
//  ArticleViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class ArticleViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var host: String?
    var urlString: String?
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = (host ?? NSLocalizedString("Article", comment: "")).uppercased()
        headerLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        
        let panGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan))
        panGestureRecognizer.edges = .left
        view.addGestureRecognizer(panGestureRecognizer)
        
        webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        webView.loadRequest(URLRequest(url: url))
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePan() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var webView: UIWebView!
    private var activityIndicator: UIActivityIndicatorView?
    
}

// MARK: - UIWebViewDelegate

extension ArticleViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
    }
}
