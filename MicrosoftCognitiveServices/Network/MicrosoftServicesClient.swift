//
//  MicrosoftServicesClient.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 11/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import Foundation
import UIKit

protocol ImageAnalyzerDelegate {
    func imageAnalyzerFinishedWithResult(result: AnalyzeImageResult)
    func imageAnalyzerFailedWithError(error: NSError?)
}

protocol ImageDescribeDelegate {
    func imageDescribeFinishedWithResult(result: DescribeImageResult)
    func imageDescribeFailedWithError(error: NSError?)
}

protocol ImageOCRDelegate {
    func imageOCRFinishedWithResult(result: OCRImageResult)
    func imageOCRFailedWithError(error: NSError?)
}

protocol ImageEmotionDelegate {
    func imageEmotionFinishedWithResult(result: [EmotionImageResultItem])
    func imageEmotionFailedWithError(error: NSError?)
}

enum ServiceType {
    case Analyze
    case Describe
    case OCR
    case Emotion
}

enum ServicePostData {
    case URL(NSURL)
    case Data(NSData)
}

struct ServiceConfiguration {
    let type: ServiceType
    let data: ServicePostData
}

protocol ServiceEndPoint {
    var path : String { get }
    var requestParameters : [String : String] { get }
    
    func url() -> NSURL
}

extension ServiceEndPoint {
    func url() -> NSURL {
        let components = NSURLComponents(string: self.path)!
        components.queryItems = self.requestParameters.map{NSURLQueryItem(name: $0.0, value: $0.1)}
        return components.URL!
    }
}

struct ServiceAnalyzeEndPoint: ServiceEndPoint {
    let path = "https://api.projectoxford.ai/vision/v1.0/analyze"
    let requestParameters = [
        "entities" : "true",
        "visualFeatures" : "Categories,Tags,ImageType,Adult,Color",
        "details" : "Celebrities",
    ]
}

struct ServiceDescribeEndPoint: ServiceEndPoint {
    let path = "https://api.projectoxford.ai/vision/v1.0/describe"
    let requestParameters = ["entities" : "true"]
}

struct ServiceOCREndPoint: ServiceEndPoint {
    let path = "https://api.projectoxford.ai/vision/v1/ocr"
    let requestParameters = [
        "entities" : "true",
        "detectOrientation" : "true"
    ]
}

struct ServiceEmotionEndPoint: ServiceEndPoint {
    let path = "https://api.projectoxford.ai/emotion/v1.0/recognize"
    let requestParameters: [String : String] = [:]
}


func createServiceRequest(configuration: ServiceConfiguration) -> NSURLRequest {
    let url : NSURL
    switch configuration.type {
    case .Analyze:
        url = ServiceAnalyzeEndPoint().url()
    case .Describe:
        url = ServiceDescribeEndPoint().url()
    case .Emotion:
        url = ServiceEmotionEndPoint().url()
    case .OCR:
        url = ServiceOCREndPoint().url()
    }
    
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    
    let contentType : String
    let httpBody : NSData
    switch configuration.data {
    case let .URL(dataURL):
        contentType = "application/json"
        httpBody = "{\"url\":\"\(dataURL.absoluteString)\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    case let .Data(data):
        contentType = "application/octet-stream"
        httpBody = data
    }
    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    request.HTTPBody = httpBody
    
    let subscriptionKey: String
    switch configuration.type {
    case .Describe:
        fallthrough
    case .OCR:
        fallthrough
    case .Analyze:
        subscriptionKey = SubscriptionKeys.ComputerVision.rawValue
    case .Emotion:
        subscriptionKey = SubscriptionKeys.Emotion.rawValue
    }
    request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    
    return request
}

func performService(serviceType: ServiceType, serviceData: ServicePostData, errorHandler: (NSError?) -> (), successHandler: (AnyObject) -> ()) -> NSURLSessionTask {
    let request = createServiceRequest(ServiceConfiguration(type: serviceType, data: serviceData))
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
        if let error = error {
            errorHandler(error)
            return
        }
        guard let data = data else {
            errorHandler(.None)
            return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            print(json)
            successHandler(json)
        } catch let error as NSError {
            errorHandler(error)
        }
    }
    task.resume()
    return task
}

func analyzeImage(serviceData: ServicePostData, delegate: ImageAnalyzerDelegate) -> NSURLSessionTask {
    return performService(.Analyze, serviceData: serviceData, errorHandler: { delegate.imageAnalyzerFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseAnalyzeImageResult(json)
            delegate.imageAnalyzerFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageAnalyzerFailedWithError(error)
        }
    }
}

func describeImage(serviceData: ServicePostData, delegate: ImageDescribeDelegate) -> NSURLSessionTask {
    return performService(.Describe, serviceData: serviceData, errorHandler: { delegate.imageDescribeFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseDescribeImageResult(json)
            delegate.imageDescribeFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageDescribeFailedWithError(error)
        }
    }
}

func ocrImage(serviceData: ServicePostData, delegate: ImageOCRDelegate) -> NSURLSessionTask {
    return performService(.OCR, serviceData: serviceData, errorHandler: { delegate.imageOCRFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseOCRImageResult(json)
            delegate.imageOCRFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageOCRFailedWithError(error)
        }
    }
}

func emotionImage(serviceData: ServicePostData, delegate: ImageEmotionDelegate) -> NSURLSessionTask {
    return performService(.Emotion, serviceData: serviceData, errorHandler: { delegate.imageEmotionFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseEmotionImageResult(json)
            delegate.imageEmotionFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageEmotionFailedWithError(error)
        }
    }
}

enum ResultOrError<T> {
    case Result(T)
    case Error(NSError?)
    
    var result: T? {
        switch self {
        case let .Result(result):
            return result
        case .Error:
            return .None
        }
    }
}

protocol MicrosoftServicesDelegate {
    func client(client: MicrosoftServicesClient, didLoadImage: UIImage)
    func client(client: MicrosoftServicesClient, didReceiveAnalyzerResult: ResultOrError<AnalyzeImageResult>)
    func client(client: MicrosoftServicesClient, didReceiveOCRResult: ResultOrError<OCRImageResult>)
    func client(client: MicrosoftServicesClient, didReceiveDescribeResult: ResultOrError<DescribeImageResult>)
    func client(client: MicrosoftServicesClient, didReceiveEmotionResult: ResultOrError<[EmotionImageResultItem]>)
}

class MicrosoftServicesClient {
    private var tasks: [NSURLSessionTask] = []
    private let delegate: MicrosoftServicesDelegate
    private var scaleFactor: CGFloat = 1
    
    internal func numberOfUnfinishedTasks() -> UInt {
        return self.tasks.reduce(0) { $0 + ($1.state == .Completed ? 0 : 1) }
    }
    
    internal func completed() -> Bool {
        return self.numberOfUnfinishedTasks() == 0
    }
    
    internal init(url: NSURL, delegate: MicrosoftServicesDelegate) {
        self.delegate = delegate
        
        let imageDownloadTask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) { (data, response, error) -> Void in
            if let data = data, image = UIImage(data: data) {
                delegate.client(self, didLoadImage: image)
                
            }
        }
        imageDownloadTask.resume()
        
        self.tasks.append(imageDownloadTask)
        self.startAnalyzingWithData(.URL(url))
    }
    
    internal init(image: UIImage, delegate: MicrosoftServicesDelegate) {
        self.delegate = delegate
        
        // reduce image-size to save bandwidth and speed up the uploading
        let scaledImage: UIImage
        let maximumSize: CGFloat = 800
        if image.size.width > maximumSize || image.size.height > maximumSize {
            (scaledImage, self.scaleFactor) = image.imageResizedToFitInBounds(CGSize(width: maximumSize, height: maximumSize), scaleOption: .Specific(1.0))
            self.scaleFactor = 1 / self.scaleFactor
        } else {
            scaledImage = image
        }
        self.delegate.client(self, didLoadImage: image)
        if let dataRepresentation = UIImageJPEGRepresentation(scaledImage, CGFloat(0.8)) {
            print("filesize: \(dataRepresentation.length), image size: \(scaledImage.size)")
            let data = ServicePostData.Data(dataRepresentation)
            self.startAnalyzingWithData(data)
        }
    }
    
    private func startAnalyzingWithData(serviceData: ServicePostData) {
        self.tasks.append(analyzeImage(serviceData, delegate: self))
        self.tasks.append(describeImage(serviceData, delegate: self))
        self.tasks.append(ocrImage(serviceData, delegate: self))
        self.tasks.append(emotionImage(serviceData, delegate: self))
    }
    
    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }
}

extension MicrosoftServicesClient: ImageAnalyzerDelegate, ImageDescribeDelegate, ImageOCRDelegate, ImageEmotionDelegate {
    func imageAnalyzerFailedWithError(error: NSError?) {
        print(error)
    }
    
    func imageAnalyzerFinishedWithResult(result: AnalyzeImageResult) {
        self.delegate.client(self, didReceiveAnalyzerResult: .Result(result))
        print(result)
    }
    
    func imageDescribeFailedWithError(error: NSError?) {
        print(error)
        self.delegate.client(self, didReceiveAnalyzerResult: .Error(error))
    }
    
    func imageDescribeFinishedWithResult(result: DescribeImageResult) {
        self.delegate.client(self, didReceiveDescribeResult: .Result(result))
        print(result)
    }
    
    func imageOCRFinishedWithResult(result: OCRImageResult) {
        let scaleStringFrame =  {
            (frameAsString: String, scaleFactor: CGFloat) -> String in
            let components = frameAsString.componentsSeparatedByString(",").map{Int($0)}
            guard components.count == 4 else {
                return frameAsString
            }
            
            let unscaledFrame = CGRect(x: components[0]!, y: components[1]!, width: components[2]!, height: components[3]!)
            let frame = CGRectIntegral(CGRectApplyAffineTransform(unscaledFrame, CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor)))
            return "\(Int(frame.origin.x)),\(Int(frame.origin.y)),\(Int(frame.width)),\(Int(frame.height))"
        }
        
        var modifiedResult = result
        // apply scale-factor that was used when the image was transferred to the server
        for regionIndex in 0..<(result.regions?.count ?? 0) {
            let region = result.regions![regionIndex]
            if let boundingBox = region.boundingBox {
                modifiedResult.regions![regionIndex].boundingBox = scaleStringFrame(boundingBox, self.scaleFactor)
            }
            for lineIndex in 0..<(region.lines?.count ?? 0) {
                let line = region.lines![lineIndex]
                if let boundingBox = line.boundingBox {
                    modifiedResult.regions![regionIndex].lines![lineIndex].boundingBox = scaleStringFrame(boundingBox, self.scaleFactor)
                }
                for wordIndex in 0..<(line.words?.count ?? 0) {
                    if let boundingBox = line.words![wordIndex].boundingBox {
                        modifiedResult.regions![regionIndex].lines![lineIndex].words![wordIndex].boundingBox = scaleStringFrame(boundingBox, self.scaleFactor)
                    }
                }
            }
        }
        self.delegate.client(self, didReceiveOCRResult: .Result(modifiedResult))
        print(result)
    }
    
    func imageOCRFailedWithError(error: NSError?) {
        print(error)
        self.delegate.client(self, didReceiveOCRResult: .Error(error))
    }
    
    func imageEmotionFailedWithError(error: NSError?) {
        print(error)
        self.delegate.client(self, didReceiveEmotionResult: .Error(error))
    }
    
    func imageEmotionFinishedWithResult(result: [EmotionImageResultItem]) {
        print(result)
        self.delegate.client(self, didReceiveEmotionResult: .Result(result))
    }

}