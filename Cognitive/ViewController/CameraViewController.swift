//
//  CameraViewController.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 30/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    @IBOutlet var cameraOverlayView: UIView!
    var appController: AppController!
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.imagePicker == nil && UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .Camera
            self.imagePicker.showsCameraControls = false
            self.imagePicker.cameraOverlayView = self.cameraOverlayView
            
            self.addChildViewController(self.imagePicker)
            self.view.addSubview(self.imagePicker.view)
            self.imagePicker.view.translatesAutoresizingMaskIntoConstraints = false
            
            self.imagePicker.view.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
            self.imagePicker.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
            self.imagePicker.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
            self.imagePicker.view.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
            
            self.imagePicker.didMoveToParentViewController(self)
        }
        
        self.cameraOverlayView.frame = self.imagePicker.view.bounds
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.performSegueWithIdentifier(MainStoryboardIdentifiers.AnalyzeImage.rawValue, sender: image)
    }
}

extension CameraViewController /* Navigation */ {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MainStoryboardIdentifiers.AnalyzeImage.rawValue {
            let controller = segue.destinationViewController as! ResultsViewController
            self.appController = AppController(withResultsCollectorDelegate: controller)
            self.appController.handleActionItem(.Image(sender as! UIImage))
        }
    }
}

extension CameraViewController /* UI Callbacks */ {
    
    @IBAction func buttonCaptureImageTapped(sender: AnyObject) {
        self.imagePicker.takePicture()
    }
}