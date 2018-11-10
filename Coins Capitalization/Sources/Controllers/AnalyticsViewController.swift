//
//  AnalyticsViewController.swift
//  Coins
//
//  Created by Artem Kirillov on 23/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class AnalyticsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backgroundColor
        
        let titleString = NSLocalizedString("Analytics", comment: "").uppercased()
        titleLabel.attributedText = NSAttributedString.attributedTitle(string: titleString)
        
        let image = UIImage(imageLiteralResourceName: "forecastSoon")
        let title = NSLocalizedString("Analytics title", comment: "")
        let message = NSLocalizedString("Analytics message", comment: "")
        let messageView = MessageView(image: image, title: title, message: message, alignment: .center)
        
        view.addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        messageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 57.0).isActive = true
        messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    // MARK: - Private properties
    
    @IBOutlet private var titleLabel: UILabel!
    
}
