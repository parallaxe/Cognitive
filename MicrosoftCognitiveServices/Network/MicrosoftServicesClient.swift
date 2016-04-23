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
    let path = "https://api.projectoxford.ai/vision/v1.0/ocr"
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

func performService(serviceType: ServiceType, onImageAtUrl url: NSURL, errorHandler: (NSError?) -> (), successHandler: (AnyObject) -> ()) -> NSURLSessionTask {
    let request = createServiceRequest(ServiceConfiguration(type: serviceType, data: .URL(url)))
    
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

func analyzeImage(url: NSURL, delegate: ImageAnalyzerDelegate) -> NSURLSessionTask {
    return performService(.Analyze, onImageAtUrl: url, errorHandler: { delegate.imageAnalyzerFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseAnalyzeImageResult(json)
            delegate.imageAnalyzerFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageAnalyzerFailedWithError(error)
        }
    }
}

func describeImage(url: NSURL, delegate: ImageDescribeDelegate) -> NSURLSessionTask {
    return performService(.Describe, onImageAtUrl: url, errorHandler: { delegate.imageDescribeFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseDescribeImageResult(json)
            delegate.imageDescribeFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageDescribeFailedWithError(error)
        }
    }
}

func ocrImage(url: NSURL, delegate: ImageOCRDelegate) -> NSURLSessionTask {
    return performService(.OCR, onImageAtUrl: url, errorHandler: { delegate.imageOCRFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseOCRImageResult(json)
            delegate.imageOCRFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageOCRFailedWithError(error)
        }
    }
}

func emotionImage(url: NSURL, delegate: ImageEmotionDelegate) -> NSURLSessionTask {
    return performService(.Emotion, onImageAtUrl: url, errorHandler: { delegate.imageEmotionFailedWithError($0) }) { (json) -> () in
        do {
            let result = try parseEmotionImageResult(json)
            delegate.imageEmotionFinishedWithResult(result)
        } catch let error as NSError {
            delegate.imageEmotionFailedWithError(error)
        }
    }
}

protocol MicrosoftServicesDelegate: ImageAnalyzerDelegate, ImageDescribeDelegate, ImageOCRDelegate, ImageEmotionDelegate {
    func client(client: MicrosoftServicesClient, didLoadImage: UIImage)
}

class MicrosoftServicesClient {
    let url: NSURL
    var tasks: [NSURLSessionTask] = []
    
    func completed() -> Bool {
        return self.tasks.reduce(true) { $0 && $1.state == .Completed }
    }
    
    init(url: NSURL, delegate: MicrosoftServicesDelegate) {
        self.url = url
        
        let imageDownloadTask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) { (data, response, error) -> Void in
            if let data = data, image = UIImage(data: data) {
                delegate.client(self, didLoadImage: image)

            }
            }
        imageDownloadTask.resume()
        
        self.tasks.append(imageDownloadTask)
        self.tasks.append(analyzeImage(url, delegate: delegate))
        self.tasks.append(describeImage(url, delegate: delegate))
        self.tasks.append(ocrImage(url, delegate: delegate))
        self.tasks.append(emotionImage(url, delegate: delegate))
    }
    
    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }
}
