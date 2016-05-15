//
//  CellWithImageView.swift
//  Cognitive
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

class CellWithImageView: UICollectionViewCell, ItemWithMaximumWidth {
    @IBOutlet weak var imageView: UIImageView!
    var maximumWidth: CGFloat!
    var intrinsicWidth: CGFloat { return self.imageView.image?.size.width ?? 1 }
    
    var views: [UIView] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for view in self.views {
            view.removeFromSuperview()
        }
    }
    
    // MARK: -
    func markEmotions(emotions: [EmotionImageResultItem]) {
        let allEmotionViews = emotions.flatMap { return self.createViewsForEmotion($0) }
        self.views.appendContentsOf(allEmotionViews)
        for view in allEmotionViews {
            self.addSubview(view)
        }
    }
    
    func markText(ocrResult: OCRImageResult) {
        guard let regions = ocrResult.regions else {
            return
        }
        let words = regions.flatMap{$0.lines}.flatMap{$0}.flatMap{$0.words}.flatMap{$0}
        let wordViews = words.flatMap {
            word -> UIView? in
            guard let boundinbBoxAsString = word.boundingBox else {
                return .None
            }
            let components = boundinbBoxAsString.componentsSeparatedByString(",").map{Int($0)}
            guard components.count == 4 else {
                return .None
            }
            let unscaledFrame = CGRect(x: components[0]!, y: components[1]!, width: components[2]!, height: components[3]!)
            let frame = CGRectApplyAffineTransform(unscaledFrame, CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor))
            let label = UILabel(frame: frame)
            label.text = word.text
            
            label.font = UIFont.systemFontOfSize(15)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.2
            label.backgroundColor = .whiteColor()
            return label
        }
        self.views.appendContentsOf(wordViews)
        for view in wordViews {
            self.addSubview(view)
        }
    }
    
    // MARK: - Helper
    
    func createViewsForEmotion(emotion: EmotionImageResultItem) -> [UIView] {
        var resultingViews: [UIView] = []
        
        guard let faceRect = emotion.faceRectangle else {
            return resultingViews
        }
        
        let unscaledFrame = CGRect(x: faceRect.left!,
            y: faceRect.top!,
            width: faceRect.width!,
            height: faceRect.height!)
        let frame = CGRectApplyAffineTransform(unscaledFrame, CGAffineTransformMakeScale(self.scaleFactor, self.scaleFactor))
        let faceView = UIView(frame: frame)
        faceView.layer.borderColor = UIColor.redColor().CGColor
        faceView.layer.borderWidth = 1
        
        resultingViews.append(faceView)
        
        guard let scores = emotion.scores else {
            return resultingViews
        }
        
        if let mainEmotion = self.getNameOfMainEmotion(scores) {
            var emotionRect = faceView.frame
            emotionRect.size.height = 20
            let emotionLabel = UILabel(frame: emotionRect)
            emotionLabel.font = UIFont.systemFontOfSize(20)
            emotionLabel.adjustsFontSizeToFitWidth = true
            emotionLabel.minimumScaleFactor = 0.5
            emotionLabel.text = mainEmotion
            emotionLabel.textColor = .redColor()
            
            resultingViews.append(emotionLabel)
        }
        
        return resultingViews
    }
    
    func getNameOfMainEmotion(emotionScores: EmotionImageResultItem.Scores) -> String? {
        let emotionNamesAndScores = ["Anger" : emotionScores.anger,
            "Contempt" : emotionScores.contempt,
            "Disgust" : emotionScores.disgust,
            "Fear" : emotionScores.fear,
            "Hapiness" : emotionScores.happiness,
            "Neutral" : emotionScores.neutral,
            "Sadness" : emotionScores.sadness,
            "Surprise" : emotionScores.surprise]
        let mainEmotion = emotionNamesAndScores.reduce(nil) {
            (result, item) -> (String, Double)? in
            guard let score = item.1 else {
                return result
            }
            guard let result = result else {
                return (item.0, score)
            }
            if score > result.1 {
                return (item.0, score)
            }
            return result
        }
        
        return mainEmotion?.0
    }
}
