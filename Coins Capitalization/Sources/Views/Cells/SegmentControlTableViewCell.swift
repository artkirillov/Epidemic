//
//  SegmentControlTableViewCell.swift
//  Coins
//
//  Created by Artem Kirillov on 31/10/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol SegmentControlTableViewCellDelegate: class {
    func segmentControlTableViewCell(cell: SegmentControlTableViewCell, changedIndex: Int)
}

class SegmentControlTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: SegmentControlTableViewCell.self)
    
    weak var delegate: SegmentControlTableViewCellDelegate?
    
    // MARK: - Constructors
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(items: [String], delegate: SegmentControlTableViewCellDelegate?) {
        segmentedControl.items = items
        self.delegate = delegate
    }
    
    @objc func changeChartType(_ sender: SegmentedControl) {
        delegate?.segmentControlTableViewCell(cell: self, changedIndex: sender.selectedIndex)
    }
    
    // MARK: - Private Properties
    
    private let animation: CATransition = {
        let animation = CATransition()
        animation.duration = 0.2
        animation.type = kCATransitionFade
        return animation
    }()
    
    private let segmentedControl = SegmentedControl()
    private let shadowImageView = UIImageView()
    
}

private extension SegmentControlTableViewCell {
    
    // MARK: - Private Methods
    
    func setupViews() {
        
        addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = Colors.backgroundColor
        
        segmentedControl.selectedIndex = 0
        segmentedControl.thumb = .line
        segmentedControl.addTarget(self, action: #selector(changeChartType), for: .valueChanged)
        
        addSubview(shadowImageView)
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        shadowImageView.image = UIImage(imageLiteralResourceName: "shadow")
    }
    
    func setupConstraints() {
        segmentedControl.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        shadowImageView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        shadowImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        shadowImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        shadowImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0).isActive = true
    }
    
}
