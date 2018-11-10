//
//  DateTimeCell.swift
//  Coins
//
//  Created by Artem Kirillov on 10/11/2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol DateTimeCellDelegate: class {
    func dateTimeCellDidRequestNewDate(cell: DateTimeCell)
    func dateTimeCellDidRequestNewTime(cell: DateTimeCell)
}

final class DateTimeCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let identifier = String(describing: DateTimeCell.self)
    
    weak var delegate: DateTimeCellDelegate?
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = Colors.backgroundColor
        
        dateBackView.backgroundColor = Colors.cellBackgroundColor
        dateBackView.layer.cornerRadius = 6.0
        
        timeBackView.backgroundColor = Colors.cellBackgroundColor
        timeBackView.layer.cornerRadius = 6.0
        
        dateLabel.textColor = Colors.majorTextColor
        dateLabel.font = Fonts.title
        
        timeLabel.textColor = Colors.majorTextColor
        timeLabel.font = Fonts.title
        
        dateSeparatorView.backgroundColor = Colors.minorTextColor
        timeSeparatorView.backgroundColor = Colors.minorTextColor
        
        dateIconView.tintColor = Colors.minorTextColor
        timeIconView.tintColor = Colors.minorTextColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        timeLabel.text = nil
    }
    
    func configure(datetitle: String, timeTitle: String) {
        dateLabel.text = datetitle
        timeLabel.text = timeTitle
    }
    
    
    
    
    // MARK: - Private Properties
    
    @IBOutlet private var dateBackView: UIView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var dateSeparatorView: UIView!
    @IBOutlet private var dateIconView: UIImageView!
    
    @IBOutlet private var timeBackView: UIView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var timeSeparatorView: UIView!
    @IBOutlet private var timeIconView: UIImageView!
    
}
