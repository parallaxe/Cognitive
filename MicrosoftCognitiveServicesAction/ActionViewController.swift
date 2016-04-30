//
//  ActionViewController.swift
//  MicrosoftCognitiveServicesAction
//
//  Created by Hendrik von Prince on 24/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit
import MobileCoreServices


func extractActionItems(extensionContext: NSExtensionContext, handler: ActionItemHandler) {
    // get all NSItemProvider-items from the extension-context
    let items: [NSItemProvider] = extensionContext.inputItems.flatMap{ $0 as? NSExtensionItem}.flatMap{ $0.attachments }.flatMap{$0}.flatMap{$0 as? NSItemProvider} ?? []
    for itemProvider in items {
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            itemProvider.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil, completionHandler: { (image_, error) in
                if let imageURL = image_ as? NSURL {
                    let image = UIImage(contentsOfFile: imageURL.path!)!
                    handler.handleActionItem(.Image(image))
                } else if let imageData = image_ as? NSData {
                    let image = UIImage(data: imageData)!
                    handler.handleActionItem(.Image(image))
                }
                
            })
        } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
                let url = url as! NSURL
                handler.handleActionItem(.URL(url))
            })
        }
    }
}

class ActionViewController: UIViewController {
    weak var mainViewController: ResultsViewController!
    var appController: AppController!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        extractActionItems(self.extensionContext!, handler: self.appController)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbeddingMainViewController" {
            self.mainViewController = segue.destinationViewController as! ResultsViewController
            self.appController = AppController(withResultsCollectorDelegate: self.mainViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

}
