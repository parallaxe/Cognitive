//
//  CellForTags.swift
//  MicrosoftCognitiveServices
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

class ViewController: UIViewController {
    @IBOutlet weak var buttonLoadImage: UIButton!
    @IBOutlet weak var textFieldForURL: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: CollectionViewLayout!
    
    var client: MicrosoftServicesClient?
    var results: Results?
    var collectionViewModel: CollectionViewModel = CollectionViewModel(results: .None)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: UI Callbacks
    
    @IBAction func userDidTapLoadImage(sender: UIButton) {
    }
}
