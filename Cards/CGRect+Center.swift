//
//  CGRect+Center.swift
//  Cards
//
//  Created by Joshua Fisher on 1/3/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: (maxX + minX) / 2,
                       y: (maxY + minY) / 2)
    }
}
