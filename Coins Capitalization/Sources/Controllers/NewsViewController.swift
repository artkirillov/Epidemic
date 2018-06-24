//
//  NewsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit
import SafariServices

final class NewsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 135.5
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        
        requestData()
    }
    
    @objc func updateData() {
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView?
    private var rssServices: [RSS] = []
    private var items: [Article] = []
    
}

// MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.configure(article: items[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
        else { return }
        
        controller.urlString = items[indexPath.row].url
        controller.host = items[indexPath.row].source.name
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Network Requests

private extension NewsViewController {
    func requestData() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let slf = self else { return }
            slf.items = []
            for feed in RSS.feeds {
                let rss = RSS()
                rss.requestNewsArticles(from: feed,
                                        completion: { articles in
                                            DispatchQueue.main.async { [weak self] in
                                                guard let slf = self else { return }
                                                slf.items = (slf.items + articles)
                                                    .sorted { ($0.publishedAt ?? Date()) > ($1.publishedAt ?? Date()) }
                                                slf.tableView.reloadData()
                                                slf.tableView.refreshControl?.endRefreshing()
                                                slf.activityIndicator?.stopAnimating()
                                            }
                })
            }
        }
    }
}
