//
//  CardsView.swift
//  Cards
//
//  Created by Joshua Fisher on 12/18/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit
import Dwifft

protocol CardsViewDelegate: class {
    func cardsView(_: CardsView, indexChanged: Int)
}

class CardsView: PassThroughView {
    
    var model: CardsViewModel {
        get { return _model }
        set { setModel(newValue, animated: false) }
    }
    
    weak var delegate: CardsViewDelegate?

    private var _model = CardsViewModel()

    private let layout: CardsLayout
    private let collectionView: UICollectionView

    private var diffCalculator: CollectionViewDiffCalculator<String, CardModel>
    
    private var maxHorizontalPeak: CGFloat = 10
    private var areEdgesClear: Bool = false

    override init(frame: CGRect) {
        layout = CardsLayout()
        layout.cardInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.horizontalPeak = maxHorizontalPeak

        collectionView = PassThroughCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.reuseIdentifier)

        diffCalculator = CollectionViewDiffCalculator(collectionView: collectionView)

        super.init(frame: frame)

        collectionView.frame = bounds
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        addSubview(collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(_ model: CardsViewModel, animated: Bool) {
        let oldValue = _model
        _model = model
        
        if (_model.stop != oldValue.stop) {
            changeStop(animated: animated)
        }
        
        if (_model.index != oldValue.index) {
            layout.centerIndex = _model.index
            // the layout will propose the targetContentOffset when its invalidated
            // to cancel that animation, set the contentOffset immediately
//            if !animated {
//                let newContentOffset = collectionView.frame.width * CGFloat(_model.index)
//                collectionView.setContentOffset(CGPoint(x: newContentOffset, y: 0), animated: false)
//            }
        }
        
        let data = SectionedValues([("only section", _model.cardModels)])
        
        if animated {
            diffCalculator.sectionedValues = data
        } else {
            diffCalculator = CollectionViewDiffCalculator(collectionView: collectionView, initialSectionedValues: data)
            collectionView.reloadData()
        }
    }
    
    private func cardCell(at index: Int) -> CardCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CardCell
    }
    
    private func changeStop(animated: Bool) {
        guard collectionView.hasContent, let centerCard = cardCell(at: _model.index) else { return }
        
        centerCard.drawer.set(stop: model.stop, animated: animated)
        
        if model.stop == .expanded {
            // side-scrolling is only enabled when the center card is expanded
            self.collectionView.isScrollEnabled = true
            showEdgeDrawersIfNeeded()
        } else {
            self.collectionView.isScrollEnabled = false
            hideEdgeDrawersIfNeeded()
        }
    }
    
    private func showEdgeDrawersIfNeeded() {
        guard collectionView.hasContent else { return }
        
        if areEdgesClear {
            areEdgesClear = false
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: { [model = _model] in
                let prevIndex = model.index - 1
                if prevIndex >= 0, let attribs = self.collectionView.layoutAttributesForItem(at: IndexPath(item: prevIndex, section: 0)) {
                    self.cardCell(at: prevIndex)?.frame = attribs.frame
                }
                
                let nextIndex = model.index + 1
                if nextIndex < model.cardModels.count, let attribs = self.collectionView.layoutAttributesForItem(at: IndexPath(item: nextIndex, section: 0)) {
                    self.cardCell(at: nextIndex)?.frame = attribs.frame
                }
            }, completion: nil)
        }
    }
    
    private func hideEdgeDrawersIfNeeded() {
        guard collectionView.hasContent else { return }
        
        if !areEdgesClear {
            areEdgesClear = true
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: { [model = _model] in
                let prevIndex = model.index - 1
                if prevIndex >= 0 {
                    self.cardCell(at: prevIndex)?.frame.origin.x -= (self.maxHorizontalPeak + 5)
                }

                let nextIndex = model.index + 1
                if nextIndex < model.cardModels.count {
                    self.cardCell(at: nextIndex)?.frame.origin.x += (self.maxHorizontalPeak + 5)
                }
            }, completion: nil)
        }
    }
}

extension CardsView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return diffCalculator.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = diffCalculator.value(atIndexPath: indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.reuseIdentifier, for: indexPath) as! CardCell
        cell.configure(with: card)

        return cell
    }
}

extension CardsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cardCell = cell as? CardCell else { fatalError() }
        cardCell.drawer.drawerDelegate = self
        cardCell.drawer.stop = .expanded
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateIndex()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateIndex()
    }
    
    private func updateIndex() {
        let page: Int
        if collectionView.contentOffset.x > 0 {
            page = Int(collectionView.contentOffset.x / collectionView.frame.width)
        } else {
            page = 0
        }
        _model.index = page
        delegate?.cardsView(self, indexChanged: page)
    }
}

extension CardsView: DrawerDelegate {
    func drawerDidBeginDragging(_ drawer: Drawer) {
        if drawer.containingCardCell == cardCell(at: _model.index) {
            hideEdgeDrawersIfNeeded()
        }
    }
    
    func drawer(_ drawer: Drawer, didMoveToStop: Drawer.Stop) {
        if drawer.containingCardCell == cardCell(at: _model.index) && drawer.stop == .expanded {
            showEdgeDrawersIfNeeded()
        }
    }
}
