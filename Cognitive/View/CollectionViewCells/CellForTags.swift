//
//  CellForTags.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

class CellForTags: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
}

class CellForHeadline: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}
