//
//  Results.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

struct Results {
    var image: UIImage?
    var analyze: ResultOrError<AnalyzeImageResult>?
    var description: ResultOrError<DescribeImageResult>?
    var ocr: ResultOrError<OCRImageResult>?
    var emotion: ResultOrError<[EmotionImageResultItem]>?
}
