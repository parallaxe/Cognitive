//
//  UIImage.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

enum ImageScaleOption {
    case UseScaleFactorFromMainScreen
    case Specific(CGFloat)
}

extension UIImage {
    func imageResizedToFitInBounds(bounds: CGSize, scaleOption: ImageScaleOption = .UseScaleFactorFromMainScreen) -> (image: UIImage, scaleFactor: CGFloat) {
        // scaling is copied and adapted from http://nshipster.com/image-resizing/
        let scaleFactor = min(bounds.width / self.size.width, bounds.height / self.size.height)
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor))
        let hasAlpha = false
        let scale: CGFloat
        switch scaleOption {
        case .UseScaleFactorFromMainScreen:
            scale = 0.0
        case let .Specific(specificScaleFactor):
            scale = specificScaleFactor
        }
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return (image: scaledImage, scaleFactor: scaleFactor)
    }
}