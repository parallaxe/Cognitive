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
    var analyze: AnalyzeImageResult?
    var description: DescribeImageResult?
    var ocr: OCRImageResult?
    var emotion: [EmotionImageResultItem]?
}
