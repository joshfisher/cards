//
//  UIColor+Hex.swift
//  Cards
//
//  Created by Joshua Fisher on 12/18/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(rgbHex: String) {
        guard let value = UInt32(rgbHex, radix: 16) else {
            return nil
        }
        let r = CGFloat((value & 0xff0000) >> 16) / 255
        let g = CGFloat((value & 0x00ff00) >> 8) / 255
        let b = CGFloat(value & 0x0000ff) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
