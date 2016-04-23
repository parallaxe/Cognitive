//
//  CollectionViewModel.swift
//  MicrosoftCognitiveServices
//
//  Created by Hendrik von Prince on 23/04/16.
//  Copyright © 2016 Hendrik von Prince. All rights reserved.
//

import UIKit

struct CollectionViewModel {
    enum Cell {
        case Image(UIImage)
        case Description(String)
        case IsAdult(Bool)
        case IsRacy(Bool)
        case Tag(String)
    }
    
    struct Section {
        let cells: [Cell]
    }
    
    let sections : [Section]
    
    init(results: Results?) {
        guard let results = results else {
            self.sections = []
            return
        }
        
        var sections : [Section] = []
        
        if let caption = results.description?.description?.captions?[0].text {
            sections.append(Section(cells: [.Description(caption)]))
        }
        
        if let image = results.image {
            sections.append(Section(cells: [.Image(image)]))
        }
        
        let isAdultContent = results.analyze?.adult?.isAdultContent
        let isRacyContent = results.analyze?.adult?.isRacyContent
        
        if let isAdultContent = isAdultContent, isRacyContent = isRacyContent {
            sections.append(Section(cells: [.IsAdult(isAdultContent != 0), .IsRacy(isRacyContent != 0)]))
        }
        
        let tagsFromDescription = results.description?.description?.tags ?? []
        let tagsFromAnalyzing = results.analyze?.tags.flatMap{$0.flatMap{$0.name}} ?? []
        let allTags = [tagsFromDescription, tagsFromAnalyzing].flatMap{$0}
        
        sections.append(Section(cells: allTags.map{.Tag($0)}))
        
        self.sections = sections
    }
}
