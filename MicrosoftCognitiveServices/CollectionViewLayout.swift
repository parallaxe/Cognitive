//
//  CollectionViewLayout.swift
//  MicrosoftCognitiveServices
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
        self.model = CollectionViewModel(results: .None)
        super.init(coder: aDecoder)
    }
    
    func calculateLayout() {
        self.layout = []
        
        guard let collectionViewBounds = self.collectionView?.bounds else {
            return
        }
        
        var y: CGFloat = 0
        for sectionIndex in (0..<self.model.sections.count) {
            var x: CGFloat = 0
            let section = self.model.sections[sectionIndex]
            for cellIndex in (0..<section.cells.count) {
                let cell = section.cells[cellIndex]
                let frame: CGRect
                switch cell {
                case let .Description(description):
                    let boundingRect = description.boundingRectWithSize(collectionViewBounds.size, options: .UsesFontLeading, attributes: [ NSFontAttributeName : fontForDescription() ], context: .None)
                    let height = ceil(boundingRect.height) + ceil(abs(boundingRect.origin.y))
                    print(height)
                    frame = CGRect(x: 0, y: y, width: collectionViewBounds.size.width, height: height)
                    y += height + spaceBetweenLines
                    x = 0
                case let .Image(image):
                    if image.size.width > collectionViewBounds.size.width {
                        frame = CGRect(x: 0, y: y, width: collectionViewBounds.width, height: (collectionViewBounds.size.width / image.size.width) * image.size.height)
                    } else {
                        frame = CGRect(x: (collectionViewBounds.size.width - image.size.width) / 2 , y: y, width: image.size.width, height: image.size.height)
                    }
                    y += frame.size.height + spaceBetweenLines
                    x = 0
                case let .Tag(tag):
                    let inset: CGFloat = 6
                    let cellSpace: CGFloat = 5
                    let labelHeight: CGFloat = 30
                    let boundingSize = CGSize(width: collectionViewBounds.width - inset * 2, height: labelHeight)
                    let boundingRect = tag.boundingRectWithSize(boundingSize, options: .UsesFontLeading, attributes: [ NSFontAttributeName : fontForTags() ], context: nil)
                    let size = CGSize(width: CGRectGetMaxX(boundingRect) + inset * 2, height: CGRectGetMaxY(boundingRect))
                    if x + size.width + cellSpace <= collectionViewBounds.width {
                        frame = CGRect(x: x, y: y, width: size.width, height: labelHeight)
                        x += size.width + cellSpace
                    } else {
                        x = 0
                        if let previousElement = self.layout.last {
                            y = CGRectGetMaxY(previousElement.attributes.frame) + spaceBetweenLines
                        }
                        frame = CGRect(x: x, y: y, width: size.width, height: labelHeight)
                        x += size.width + cellSpace
                    }
                case .IsAdult:
                    frame = CGRect(x: 0, y: y, width: collectionViewBounds.width, height: 20)
                    y += frame.size.height + spaceBetweenLines
                case .IsRacy:
                    frame = CGRect(x: 0, y: y, width: collectionViewBounds.width, height: 20)
                    y += frame.size.height + spaceBetweenLines
                }
                let indexPath = NSIndexPath(forItem: cellIndex, inSection: sectionIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = frame
                
                self.layout.append((indexPath: indexPath, attributes: attributes))
            }
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
        return self.layout.filter { element -> Bool in
            CGRectIntersectsRect(element.attributes.frame, rect)
            }.map {
                return $0.attributes
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return false
    }
}
