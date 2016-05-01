//
//  CollectionViewLayout.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

/**
 Due to errors in UICollectionViewFlowLayout combined with autolayout (for example http://www.openradar.me/25303115), I
 improvised this layout.
 */
class CollectionViewLayout: UICollectionViewLayout {
    var model: CollectionViewModel {
        didSet {
            self.calculateLayout()
        }
    }
    let spaceBetweenLines: CGFloat = 10
    var layout: [(indexPath: NSIndexPath, attributes: UICollectionViewLayoutAttributes)] = []
    
    required init?(coder aDecoder: NSCoder) {
        self.model = CollectionViewModel(results: .None, isStillLoading: false)
        super.init(coder: aDecoder)
    }
    
    func calculateLayout() {
        // clean the layout at the beginning - layout-items will be appended to this array
        self.layout = []
        
        guard let collectionViewBounds = self.collectionView?.bounds else {
            return
        }
        
        enum LayoutItemType {
            case TextLine(height: CGFloat, index: NSIndexPath)
            case TextItem(width: CGFloat, index: NSIndexPath)
            case Image(size: CGSize, index: NSIndexPath)
            
            var itemIndex: NSIndexPath {
                switch self {
                case let .TextItem(_, index):
                    return index
                case let .TextLine(_, index):
                    return index
                case let .Image(_, index):
                    return index
                }
            }
        }
        
        let layoutItems = self.model.sections.mapWithIndex {
            sectionIndex, section -> [LayoutItemType] in
            return section.cells.mapWithIndex {
                cellIndex, cell -> LayoutItemType in
                let itemIndex = NSIndexPath(forItem: cellIndex, inSection: sectionIndex)
                switch cell {
                case let .Description(description):
                    let boundingRect = description.boundingRectWithSize(collectionViewBounds.size, options: .UsesFontLeading, attributes: [ NSFontAttributeName : fontForDescription() ], context: .None)
                    let height = ceil(boundingRect.height) + ceil(abs(boundingRect.origin.y))
                    return .TextLine(height: height, index: itemIndex)
                case let .Image(image):
                    if image.size.width > collectionViewBounds.size.width {
                        return .Image(size: CGSize(width: collectionViewBounds.width, height: (collectionViewBounds.size.width / image.size.width) * image.size.height), index: itemIndex)
                    } else {
                        return .Image(size: CGSize(width: image.size.width, height: image.size.height), index: itemIndex)
                    }
                case let .Tag(tag):
                    let inset: CGFloat = 6
                    let labelHeight: CGFloat = 20
                    let boundingRect = tag.boundingRectWithSize(CGSize(width: collectionViewBounds.width - inset * 2, height: labelHeight), options: .UsesFontLeading, attributes: [ NSFontAttributeName : fontForTags() ], context: nil)
                    let width = CGRectGetMaxX(boundingRect) + inset * 2
                    return .TextItem(width: width, index: itemIndex)
                case .IsAdult:
                    fallthrough
                case .IsRacy:
                    return .TextLine(height: 20, index: itemIndex)
                case .LoadingInformation:
                    return .TextLine(height: 30, index: itemIndex)
                }
            }
        }
        
        var y: CGFloat = 0
        var x: CGFloat = 0
        var attributesOfPreviousElement: UICollectionViewLayoutAttributes?
        self.layout = layoutItems.flatMap{$0}.map {
            layoutItem -> (indexPath: NSIndexPath, attributes: UICollectionViewLayoutAttributes) in
            let frame: CGRect
            let itemIndex = layoutItem.itemIndex
            switch layoutItem {
            case let .TextLine(height, _):
                x = 0
                frame = CGRect(x: 0, y: y, width: collectionViewBounds.width, height: height)
                y += frame.size.height + spaceBetweenLines
            case let .TextItem(width, _):
                let cellSpace: CGFloat = 5
                let labelHeight: CGFloat = 30
                if x + width + cellSpace <= collectionViewBounds.width {
                    frame = CGRect(x: x, y: y, width: width, height: labelHeight)
                } else {
                    x = 0
                    if let attributesOfPreviousElement = attributesOfPreviousElement {
                        y = CGRectGetMaxY(attributesOfPreviousElement.frame) + spaceBetweenLines
                    }
                    frame = CGRect(x: x, y: y, width: width, height: labelHeight)
                }
                x += width + cellSpace
            case let .Image(size, _):
                if size.width > collectionViewBounds.size.width {
                    frame = CGRect(x: 0, y: y, width: collectionViewBounds.width, height: (collectionViewBounds.size.width / size.width) * size.height)
                } else {
                    frame = CGRect(x: (collectionViewBounds.size.width - size.width) / 2 , y: y, width: size.width, height: size.height)
                }
                y += frame.size.height + spaceBetweenLines
                x = 0
            }
            
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: itemIndex)
            attributes.frame = frame
            attributesOfPreviousElement = attributes
            return (indexPath: itemIndex, attributes: attributes)
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        guard let collectionViewBounds = self.collectionView?.bounds else {
            return CGSizeZero
        }
        
        guard let lastElement = self.layout.last else {
            return CGSizeZero
        }
        
        return CGSize(width: collectionViewBounds.width, height: CGRectGetMaxY(lastElement.attributes.frame))
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        for element in self.layout {
            if element.indexPath == indexPath {
                return element.attributes
            }
        }
        
        return nil
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layout.filter {
                element -> Bool in
                CGRectIntersectsRect(element.attributes.frame, rect)
            }.map {
                return $0.attributes
            }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
