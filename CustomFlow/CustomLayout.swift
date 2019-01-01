//
//  CustomLayout.swift
//  CustomFlow
//
//  Created by Németh Gergely on 2018. 12. 19..
//  Copyright © 2018. Németh Gergely. All rights reserved.
//

import UIKit

protocol CustomLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class CustomLayout: UICollectionViewLayout {

    weak var delegate: CustomLayoutDelegate?

    private var cachedAttributes = [UICollectionViewLayoutAttributes]()

    private var insertingIndexPaths = [IndexPath]()
    private var removingIndexPaths = [IndexPath]()

    var numberOfColumns: Int {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return 4
        }
        return 2
    }
    var cellPadding: CGFloat = 20 { didSet { invalidateLayout() } }

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        cachedAttributes = prepareGridLayout()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }

        return !newBounds.size.equalTo(collectionView.bounds.size)
    }


    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemsForElements(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate, update.updateAction == .insert {
                insertingIndexPaths.append(indexPath)
            }

            if let indexPath = update.indexPathBeforeUpdate, update.updateAction == .delete {
                removingIndexPaths.append(indexPath)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        insertingIndexPaths.removeAll()
        removingIndexPaths.removeAll()
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }

        let newAttributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        newAttributes.transform = attributes.transform
        newAttributes.frame = attributes.frame

        if insertingIndexPaths.contains(itemIndexPath) {
            let translationX = attributes.frame.minX < contentWidth / 2 ? -contentWidth : contentWidth
            let scale = 1/(2 + CGFloat(arc4random_uniform(6)))
            newAttributes.transform = CGAffineTransform(translationX: translationX, y: 0).scaledBy(x: scale, y: scale)
            return newAttributes
        }

        return newAttributes

    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }

        let newAttributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
        newAttributes.transform = attributes.transform
        newAttributes.frame = attributes.frame

        if removingIndexPaths.contains(itemIndexPath) {
            let translationX = attributes.frame.minX < contentWidth / 2 ? -contentWidth : contentWidth
            let scale = 1/(2 + CGFloat(arc4random_uniform(6)))
            newAttributes.transform = CGAffineTransform(translationX: translationX, y: 0).scaledBy(x: scale, y: scale)
            return newAttributes
        }

        return newAttributes
    }

    // This implementation fixes an animation glitch when deleting an item
    // https://stackoverflow.com/a/20969727/5202549
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let cv = collectionView else { return proposedContentOffset }
        if collectionViewContentSize.height <= cv.bounds.size.height - cv.contentInset.top - cv.contentInset.bottom {
            return CGPoint(x: proposedContentOffset.x, y: -cv.contentInset.top)
        }
        return proposedContentOffset
    }
}

extension CustomLayout {

    private func prepareGridLayout() -> [UICollectionViewLayoutAttributes] {
        guard let collectionView = collectionView, let delegate = delegate else { return [] }
        let columnWidth = (contentWidth - (CGFloat(numberOfColumns) - 1) * cellPadding) / CGFloat(numberOfColumns)
        let xOffset = (0..<numberOfColumns).map { return CGFloat($0) * (columnWidth + cellPadding) }
        contentHeight = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        return (0..<collectionView.numberOfItems(inSection: 0)).map {
            let currentColumn = yOffset.firstIndex(of: yOffset.min() ?? 0) ?? 0 // get smallest column
            let indexPath = IndexPath(item: $0, section: 0)

            let itemHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let frame = CGRect(x: xOffset[currentColumn], y: yOffset[currentColumn], width: columnWidth, height: itemHeight)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[currentColumn] = yOffset[currentColumn] + itemHeight + cellPadding

            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame

            return attribute
        }
    }

    private func itemsForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var attributesArray = [UICollectionViewLayoutAttributes]()

        guard let firstMatch = binarySearchAttributes(range: 0..<cachedAttributes.count, in: rect) else { return attributesArray }

        for attributes in cachedAttributes[..<firstMatch].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }

        for attributes in cachedAttributes[firstMatch...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        return attributesArray
    }

    private func binarySearchAttributes(range: Range<Int>, in rect: CGRect) -> Int? {
        if range.lowerBound >= range.upperBound {
            return nil
        } else {
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            if cachedAttributes[midIndex].frame.maxY < rect.minY {
                return binarySearchAttributes(range: midIndex+1..<range.upperBound, in: rect)
            } else if cachedAttributes[midIndex].frame.minY > rect.maxY {
                return binarySearchAttributes(range: range.lowerBound..<midIndex, in: rect)
            } else {
                return midIndex
            }
        }
    }
}
