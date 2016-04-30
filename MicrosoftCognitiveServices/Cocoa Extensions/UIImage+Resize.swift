//
//  UIImage.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

extension UIImage {
    func imageResizedToFitInBounds(bounds: CGSize) -> UIImage {
        // scaling is copied and adapted from http://nshipster.com/image-resizing/
        let scaleFactor = bounds.width / self.size.width
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}