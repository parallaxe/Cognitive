//
//  Array+MapWithIndex.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import Foundation

extension Array {
    func mapWithIndex<T>(@noescape transform: (Int, Element) throws -> T) rethrows -> [T] {
        return try self.enumerate().map(transform)
    }
    
    func flatMapWithIndex<T>(@noescape transform: (Int, Element) throws -> T?) rethrows -> [T] {
        return try self.enumerate().flatMap(transform)
    }
}