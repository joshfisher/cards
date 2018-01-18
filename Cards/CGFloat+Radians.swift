//
//  CGFloat+Radians.swift
//  Cards
//
//  Created by Joshua Fisher on 12/19/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit

typealias Radians = CGFloat
typealias Degrees = CGFloat

extension Radians {
    var degrees: Degrees { return self / CGFloat.pi * 180 }
}

extension Degrees {
    var radians: Radians { return self / 180 * CGFloat.pi }
}
