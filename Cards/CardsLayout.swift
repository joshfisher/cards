//
//  CardsLayout.swift
//  Cards
//
//  Created by Joshua Fisher on 12/18/17.
//  Copyright © 2017 Joshua Fisher. All rights reserved.
//

import UIKit

class CardsLayout: UICollectionViewLayout {
    
    var cardInset: UIEdgeInsets = .zero
    var horizontalPeak: CGFloat = 20

    // used to set the targetOffset when inserting/removing/moving
    var centerIndex: Int = 0

    private var contentSize = CGSize.zero
    
    private var insertingIndexes = Set<IndexPath>()
    private var deletingIndexes = Set<IndexPath>()
    
    private var previousCenter: CGFloat = 0

    override func prepare() {
        guard let collectionView = collectionView, collectionView.hasContent else { return }

        let maxOffset = collectionView.numberOfItems(inSection: 0)
        contentSize = CGSize(width: collectionView.frame.width * CGFloat(maxOffset),
                             height: collectionView.frame.height)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (0 ..< collectionView!.numberOfItems(inSection: 0)).map {
            return adjustAttributes(attributes(at: $0), relativeTo: collectionView!.bounds.center.x)
        }
    }

    // returns nil if indexPath is out of bounds of the dataSource
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return adjustAttributes(attributes(at: indexPath.item), relativeTo: collectionView!.bounds.center.x)
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    private func attributes(at index: Int) -> UICollectionViewLayoutAttributes {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
        attribs.frame = CGRect(origin: CGPoint(x: CGFloat(index) * collectionView!.frame.width, y: 0),
                               size: collectionView!.frame.size)
        return attribs
    }

    // adjustments are made based on proximity to center of collectionView.bounds
    // returns an adjusted copy
    private func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes, relativeTo center: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributesCopy = attributes.copy() as! UICollectionViewLayoutAttributes
        
        let visibleWidth = collectionView!.frame.width

        let distance = center - attributesCopy.frame.center.x
        let pct = abs(distance) / visibleWidth / 8
        let comp = (attributesCopy.frame.width / 2) * (distance > 0 ? 1 : -1)
        let scale = 1 - pct

        var frame = UIEdgeInsetsInsetRect(attributesCopy.frame, cardInset)
        frame.origin.x += (distance / visibleWidth) * (horizontalPeak + (cardInset.left + cardInset.right) / 2)

        if scale < 1 {
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, comp, frame.height / 2, 0)
            transform = CATransform3DScale(transform, scale, scale, 1)
            transform = CATransform3DTranslate(transform, -comp, -frame.height / 2, 0)
            attributesCopy.transform3D = transform
        }
        
        attributesCopy.frame = frame
        return attributesCopy
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for item in updateItems {
            switch item.updateAction {
            case .insert:
                insertingIndexes.insert(item.indexPathAfterUpdate!)
                
            case .delete:
                deletingIndexes.insert(item.indexPathBeforeUpdate!)
                
            default:
                break
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        insertingIndexes.removeAll()
        deletingIndexes.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = adjustAttributes(attributes(at: itemIndexPath.item), relativeTo: collectionView!.bounds.midX)

        if insertingIndexes.contains(itemIndexPath) {
            // new card, start it off the bottom of the screen, compensating for offset change
            attribs.frame.origin.x += (previousCenter - collectionView!.bounds.midX)
            attribs.frame.origin.y += attribs.frame.height / 2
        }
        
        return attribs
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // adjust side cards relative to the previous contentOffset so their transforms will be correct
        let attribs = adjustAttributes(attributes(at: itemIndexPath.item), relativeTo: previousCenter)
        
        if deletingIndexes.contains(itemIndexPath) {
            // slide disappearing cards straight down, compensating for offset change
            attribs.frame.origin.x += (collectionView!.bounds.midX - previousCenter)
            attribs.frame.origin.y += attribs.frame.height / 2
        }
        
        return attribs
    }
    
    /*
     called after prepare()
     if you return a point different than proposedContentOffset
        - the collectionView's contentOffset is updated immedately
        - prepare is called again
     */
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        previousCenter = collectionView.bounds.midX

        let newContentOffset = collectionView.frame.width * CGFloat(centerIndex)
        return CGPoint(x: newContentOffset, y: 0)
    }
}

extension UICollectionView {
    var hasContent: Bool {
        return numberOfSections > 0 && numberOfItems(inSection: 0) > 0
    }
}
