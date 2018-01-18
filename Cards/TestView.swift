//
//  TestView.swift
//  Cards
//
//  Created by Joshua Fisher on 1/4/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

class TestView: UIView {
    init(frame: CGRect, palette: [UIColor]) {
        super.init(frame: frame)

        for i in 0 ..< 50 {
            let sub = UIView(frame: .zero)
            sub.backgroundColor = palette[i % palette.count]
            addSubview(sub)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        let subHeight = bounds.height / CGFloat(subviews.count)
        for (i, sub) in subviews.enumerated() {
            sub.frame = CGRect(x: 0, y: CGFloat(i) * subHeight, width: bounds.width, height: subHeight)
        }
    }
}
