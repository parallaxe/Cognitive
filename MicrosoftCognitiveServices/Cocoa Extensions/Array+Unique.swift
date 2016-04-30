//
//  Array+Unique.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func uniq() -> Array<Element> {
        var result: [Element] = []
        for x in self {
            if !result.contains(x) {
                result.append(x)
            }
        }
        return result
    }
}