//
//  ButtonInputAccessoryView.swift
//  Coins
//
//  Created by Artem Kirillov on 23/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol ButtonInputAccessoryViewDelegate: class {
    func buttonInputAccessoryViewDidTap(view: ButtonInputAccessoryView)
}

final class ButtonInputAccessoryView: UIView {
    
    // MARK: - Public Properties
    
    weak var delegate: ButtonInputAccessoryViewDelegate?
    
    // MARK: - Constructors
    
    init(title: String?) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: Layout.buttonHeight + 2 * Layout.smallMargin))

        button.setTitle(title, for: .normal)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Properties
    
    private let backgroundView = UIVisualEffectView()
    private let button = UIButton()
}

private extension ButtonInputAccessoryView {
    
    // MARK: - Private Nested
    
    struct Layout {
        static let buttonHeight: CGFloat = 44.0
        static let smallMargin: CGFloat = 8.0
        static let bigMargin: CGFloat = 50.0
        static let margin: CGFloat = 20.0
    }
    
    // MARK: - Private Methods
    
    func setupViews() {
        addSubview(backgroundView)
        backgroundView.effect = UIBlurEffect(style: .dark)
        
        addSubview(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = Layout.buttonHeight / 2
        button.backgroundColor = Colors.blueColor
        button.setTitleColor(Colors.minorTextColor, for: .highlighted)
        button.setTitleColor(Colors.majorTextColor, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitle
    }
    
    func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor, constant: Layout.smallMargin).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.smallMargin).isActive = true
        button.heightAnchor.constraint(equalToConstant: Layout.buttonHeight).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.bigMargin).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.bigMargin).isActive = true
    }
    
    @objc func buttonTapped() {
        delegate?.buttonInputAccessoryViewDidTap(view: self)
    }
    
}
