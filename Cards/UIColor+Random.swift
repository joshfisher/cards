//
//  UIColor+Random.swift
//  Cards
//
//  Created by Joshua Fisher on 1/12/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let b = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
