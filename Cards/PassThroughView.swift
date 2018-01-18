//
//  TouchForwardingScrollView.swift
//  Cards
//
//  Created by Joshua Fisher on 1/12/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
