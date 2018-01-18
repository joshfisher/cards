//
//  CardCell.swift
//  Cards
//
//  Created by Joshua Fisher on 1/4/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: self)
    
    var scrollView: UIScrollView
    var drawer: Drawer
    var scrollViewContent: UIView?
    
    override init(frame: CGRect) {
        scrollView = UIScrollView(frame: frame.with(origin: .zero))
        drawer = Drawer(scrollView: scrollView)
        
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear

        scrollView.clipsToBounds = true
        scrollView.layer.cornerRadius = 10
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        drawer.frame = bounds
        contentView.addSubview(drawer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in contentView.subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
    override func prepareForReuse() {
        scrollViewContent?.removeFromSuperview()
    }

    func configure(with model: CardModel) {
        if case CardModel.plain(_, let palette) = model {
            let testView = TestView(frame: bounds.with(height: 1200), palette: palette)
            scrollView.contentSize = testView.bounds.size
            scrollView.addSubview(testView)
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
    }
}

extension UIView {
    var containingCardCell: CardCell? {
        var view = superview
        while view != nil {
            if view is CardCell {
                return view as? CardCell
            }
            view = view?.superview
        }
        return nil
    }
}
