//
//  ResultsAggregator.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

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
