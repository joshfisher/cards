//
//  CGRect+UIEdgeInsets.swift
//  Cards
//
//  Created by Joshua Fisher on 12/19/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit

extension CGRect {
    func insetBy(_ edgeInsets: UIEdgeInsets) -> CGRect {
        return CGRect(x: minX + edgeInsets.left,
                      y: minY + edgeInsets.top,
                      width: width - (edgeInsets.left + edgeInsets.right),
                      height: height - (edgeInsets.top + edgeInsets.bottom))
    }
}
