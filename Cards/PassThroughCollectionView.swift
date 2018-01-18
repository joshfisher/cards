//
//  PassThroughCollectionView.swift
//  Cards
//
//  Created by Joshua Fisher on 1/15/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

class PassThroughCollectionView: UICollectionView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in visibleCells {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
