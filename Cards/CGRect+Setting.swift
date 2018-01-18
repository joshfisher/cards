//
//  CGRect+Updated.swift
//  Cards
//
//  Created by Joshua Fisher on 1/9/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

extension CGRect {
    func with(origin: CGPoint) -> CGRect {
        return self.with(x: origin.x, y: origin.y)
    }
    
    func with(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> CGRect {
        var copy: CGRect = .zero
        copy.origin.x = x ?? minX
        copy.origin.y = y ?? minY
        copy.size.width = width ?? self.width
        copy.size.height = height ?? self.height
        return copy
    }
}
