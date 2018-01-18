//
//  CGSize+Setting.swift
//  Cards
//
//  Created by Joshua Fisher on 1/9/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

extension CGSize {
    func with(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        var copy: CGSize = .zero
        copy.width = width ?? self.width
        copy.height = height ?? self.height
        return copy
    }
}
