//
//  MessageView.swift
//  Coins
//
//  Created by Artem Kirillov on 02.10.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class MessageView: UIView {
    
    // MARK: - Public Nested
    
    enum Alighment {
        case standard
        case center
    }
    
    // MARK: - Public Properties
    
    var alignment: Alighment = .standard
    
    // MARK: - Constructors
    
    init(image: UIImage?, title: String?, message: String?, alignment: Alighment = .standard) {
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 500.0))
        
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        self.alignment = alignment
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Properties
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let button = UIButton()
}

private extension MessageView {
    
    // MARK: - Private Methods
    
    func setupViews() {
        [imageView, titleLabel, messageLabel, button].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.numberOfLines = 2
        titleLabel.textColor = Colors.majorTextColor
        titleLabel.font = Fonts.messageTitle
        titleLabel.textAlignment = .center
        
        messageLabel.numberOfLines = 0
        messageLabel.textColor = Colors.minorTextColor
        messageLabel.font = Fonts.messageText
        messageLabel.textAlignment = .center
    }
    
    func setupConstraints() {
        
        let topMargin: CGFloat = alignment == .standard ? 40.0 : 132.0
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: topMargin).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.0).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15.0).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.0).isActive = true
        
        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20.0).isActive = true
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
}
