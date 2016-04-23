//
//  ItemWithMaximumWidth.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

protocol ItemWithMaximumWidth {
    var maximumWidth: CGFloat! { get set }
    var intrinsicWidth: CGFloat { get }
    var scaleFactor: CGFloat { get }
}

extension ItemWithMaximumWidth {
    var scaleFactor: CGFloat {
        if self.intrinsicWidth > self.maximumWidth {
            return self.maximumWidth / self.intrinsicWidth
        } else {
            return 1
        }
    }
}
