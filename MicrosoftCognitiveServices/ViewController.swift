//
//  ViewController.swift
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

class ViewController: UICollectionViewController {
    @IBOutlet private weak var layout: CollectionViewLayout!
    
    private var results: Results = Results()
    private var collectionViewModel: CollectionViewModel = CollectionViewModel(results: .None, isStillLoading: false)
    
}


protocol ResultsCollectorDelegate {
    func updatedResults(results: Results, finished: Bool)
}

class ResultsAggregator: MicrosoftServicesDelegate {
    private let delegate: ResultsCollectorDelegate
    private var results: Results = Results()

    init(delegate: ResultsCollectorDelegate) {
        self.delegate = delegate
    }
    
    func client(client: MicrosoftServicesClient, didLoadImage image: UIImage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.results.image = image
            self.delegate.updatedResults(self.results, finished: client.completed())
        }
    }
    
    func client(client: MicrosoftServicesClient, didReceiveOCRResult ocrResult: ResultOrError<OCRImageResult>) {
        self.results.ocr = ocrResult
        self.delegate.updatedResults(self.results, finished: client.completed())
    }
    
    func client(client: MicrosoftServicesClient, didReceiveAnalyzerResult analyzeResult: ResultOrError<AnalyzeImageResult>) {
        self.results.analyze = analyzeResult
        self.delegate.updatedResults(self.results, finished: client.completed())
    }
    
    func client(client: MicrosoftServicesClient, didReceiveDescribeResult describeResult: ResultOrError<DescribeImageResult>) {
        self.results.description = describeResult
        self.delegate.updatedResults(self.results, finished: client.completed())
    }
    
    func client(client: MicrosoftServicesClient, didReceiveEmotionResult emotionResult: ResultOrError<[EmotionImageResultItem]>) {
        self.results.emotion = emotionResult
        self.delegate.updatedResults(self.results, finished: client.completed())
    }
}

extension ViewController: ResultsCollectorDelegate {
    func updatedResults(results: Results, finished: Bool) {
        self.results = results
        self.updateUIAfterNewResult(finished: finished)
    }
}

extension ViewController /* UI Updates */ {
    func updateUIAfterNewResult(finished finished: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionViewModel = CollectionViewModel(results: self.results, isStillLoading: !finished)
            self.layout.model = self.collectionViewModel
            self.collectionView!.reloadData()
        }
    }
}

extension ViewController /* UICollectionViewDataSource */ {
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
