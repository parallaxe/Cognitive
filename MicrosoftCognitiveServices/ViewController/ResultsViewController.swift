//
//  ResultsViewController.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 06/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit
import MobileCoreServices

func fontForDescription() -> UIFont {
    return UIFont.boldSystemFontOfSize(30)
}

func fontForTags() -> UIFont {
    return UIFont.systemFontOfSize(17)
}

class ResultsViewController: UICollectionViewController {
    @IBOutlet private weak var layout: CollectionViewLayout!
    
    private var results: Results = Results()
    private var collectionViewModel: CollectionViewModel = CollectionViewModel(results: .None, isStillLoading: false)
}

extension ResultsViewController: ResultsCollectorDelegate {
    internal func updatedResults(results: Results, finished: Bool) {
        self.results = results
        self.updateUIAfterNewResult(finished: finished)
    }
}

extension ResultsViewController /* UI Updates */ {
    private func updateUIAfterNewResult(finished finished: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionViewModel = CollectionViewModel(results: self.results, isStillLoading: !finished)
            self.layout.model = self.collectionViewModel
            self.collectionView!.reloadData()
        }
    }
}

extension ResultsViewController /* UICollectionViewDataSource */ {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewModel.sections[section].cells.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.collectionViewModel.sections.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch self.collectionViewModel.sections[indexPath.section].cells[indexPath.row] {
        case let .Image(image):
            let cell: CellWithImageView = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellWithImageView", forIndexPath: indexPath) as! CellWithImageView
            cell.imageView.image = image
            cell.maximumWidth = collectionView.bounds.size.width
            
            if case let .Result(emotions)? = self.results.emotion {
                cell.markEmotions(emotions);
            }
            if case let .Result(ocr)? = self.results.ocr {
                cell.markText(ocr)
            }
            return cell
        case let .Description(description):
            let cell: CellForHeadline = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellForHeadline", forIndexPath: indexPath) as! CellForHeadline
            cell.label.text = description
            cell.label.font = fontForDescription()
            return cell
        case let .Tag(tag):
            let cell: CellForTags = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellForTags", forIndexPath: indexPath) as! CellForTags
            cell.label.font = fontForTags()
            cell.label.text = tag
            return cell
        case let .IsAdult(isAdult):
            let cell: CellForFullLineText = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellForFullLineText", forIndexPath: indexPath) as! CellForFullLineText
            cell.label.text = "Adultery? \(isAdult ? "Don't show that to your kids!" : "Nope")"
            return cell
        case let .IsRacy(isRacy):
            let cell: CellForFullLineText = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellForFullLineText", forIndexPath: indexPath) as! CellForFullLineText
            cell.label.text = "Racy? \(isRacy ? "Seems so" : "Nope")"
            return cell
        case .LoadingInformation:
            let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CellForLoading", forIndexPath: indexPath)
            return cell
        }
    }
}
