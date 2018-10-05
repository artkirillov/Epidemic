//
//  Colors.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

struct Colors {
    static let lightBlueColor = UIColor(red: 96/255, green: 111/255, blue: 238/255, alpha: 1.0)
    static let blueColor = UIColor(red: 49/255, green: 49/255, blue: 109/255, alpha: 1.0)
    static let backgroundColor = UIColor(red: 27/255, green: 27/255, blue: 35/255, alpha: 1.0)
    static let cellBackgroundColor = UIColor(red: 37/255, green: 37/255, blue: 46/255, alpha: 1.0)
    static let majorTextColor = UIColor.white
    static let minorTextColor = UIColor(red: 170/255, green: 170/255, blue: 180/255, alpha: 1.0)
    
    static let controlHighlighted = Colors.lightBlueColor
    static let controlEnabled = Colors.lightBlueColor
    static let controlDisabled = Colors.blueColor
    static let controlTextEnabled = UIColor.white
    static let controlTextDisabled = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    
    static let positiveGrow = UIColor(red: 9/255, green: 222/255, blue: 183/255, alpha: 1.0)
    static let negativeGrow = UIColor(red: 203/255, green: 33/255, blue: 98/255, alpha: 1.0)
    static let bubbleBackground = Colors.cellBackgroundColor
    static let actionButtonBackground = Colors.blueColor
}
