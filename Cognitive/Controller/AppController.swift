//
//  AppController.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

enum ActionItem {
    case URL(NSURL)
    case Image(UIImage)
}

protocol ActionItemHandler {
    func handleActionItem(actionItem: ActionItem)
}

class AppController: ActionItemHandler {
    private let resultsCollectorDelegate: ResultsCollectorDelegate
    private var client: MicrosoftServicesClient!
    private var resultsAggregator: ResultsAggregator!
    
    internal init(withResultsCollectorDelegate resultsCollectorDelegate: ResultsCollectorDelegate) {
        self.resultsCollectorDelegate = resultsCollectorDelegate
    }
    
    func handleActionItem(actionItem: ActionItem) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.resultsAggregator = ResultsAggregator(delegate: self.resultsCollectorDelegate)
            switch actionItem {
            case let .Image(image):
                self.client = MicrosoftServicesClient(image: image, delegate: self.resultsAggregator)
            case let .URL(url):
                self.client = MicrosoftServicesClient(url: url, delegate: self.resultsAggregator)
            }
        }
    }
}
