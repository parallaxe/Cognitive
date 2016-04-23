//
//  ViewController.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 06/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

func fontForDescription() -> UIFont {
    return UIFont.boldSystemFontOfSize(30)
}

func fontForTags() -> UIFont {
    return UIFont.systemFontOfSize(17)
}

extension ViewController: MicrosoftServicesDelegate {
    
    func client(client: MicrosoftServicesClient, didLoadImage image: UIImage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.results?.image = image
            self.updateUIAfterNewResult()
        }
    }
    
    func imageAnalyzerFailedWithError(error: NSError?) {
        print(error)
    }
    
    func imageAnalyzerFinishedWithResult(result: AnalyzeImageResult) {
        self.results?.analyze = result
        self.updateUIAfterNewResult()
        print(result)
    }

    func imageDescribeFailedWithError(error: NSError?) {
        print(error)
    }
    
    func imageDescribeFinishedWithResult(result: DescribeImageResult) {
        self.results?.description = result
        self.updateUIAfterNewResult()
        print(result)
    }

    func imageOCRFinishedWithResult(result: OCRImageResult) {
        self.results?.ocr = result
        self.updateUIAfterNewResult()
        print(result)
    }
    
    func imageOCRFailedWithError(error: NSError?) {
        print(error)
    }

    func imageEmotionFailedWithError(error: NSError?) {
        print(error)
    }
    
    func imageEmotionFinishedWithResult(result: [EmotionImageResultItem]) {
        self.results?.emotion = result
        self.updateUIAfterNewResult()
        print(result)
    }
}

extension ViewController /* Update after new result */ {
    func updateUIAfterNewResult() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionViewModel = CollectionViewModel(results: self.results)
            self.collectionViewLayout.model = self.collectionViewModel
            self.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewModel.sections[section].cells.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.collectionViewModel.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch self.collectionViewModel.sections[indexPath.section].cells[indexPath.row] {
        case let .Image(image):
            let cell: CellWithImageView = self.collectionView.dequeueReusableCellWithReuseIdentifier("CellWithImageView", forIndexPath: indexPath) as! CellWithImageView
            cell.imageView.image = image
            cell.maximumWidth = collectionView.bounds.size.width
            
            if let emotions = self.results?.emotion {
                cell.markEmotions(emotions);
            }
            if let ocr = self.results?.ocr {
                cell.markText(ocr)
            }
            return cell
        case let .Description(description):
            let cell: CellForHeadline = self.collectionView.dequeueReusableCellWithReuseIdentifier("CellForHeadline", forIndexPath: indexPath) as! CellForHeadline
            cell.label.text = description
            cell.label.font = fontForDescription()
            return cell
        case let .Tag(tag):
            let cell: CellForTags = self.collectionView.dequeueReusableCellWithReuseIdentifier("CellForTags", forIndexPath: indexPath) as! CellForTags
            cell.label.font = fontForTags()
            cell.label.text = tag
            return cell
        case let .IsAdult(isAdult):
            let cell: CellForFullLineText = self.collectionView.dequeueReusableCellWithReuseIdentifier("CellForFullLineText", forIndexPath: indexPath) as! CellForFullLineText
            cell.label.text = "Adultery? \(isAdult ? "Don't show that to your kids!" : "Nope")"
            return cell
        case let .IsRacy(isRacy):
            let cell: CellForFullLineText = self.collectionView.dequeueReusableCellWithReuseIdentifier("CellForFullLineText", forIndexPath: indexPath) as! CellForFullLineText
            cell.label.text = "Racy? \(isRacy ? "Seems so" : "Nope")"
            return cell
        }
        
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let url = NSURL(string: self.textFieldForURL.text!)!
        
        self.results = Results()
        self.client = MicrosoftServicesClient(url: url, delegate: self)
        
        return false
    }
}
