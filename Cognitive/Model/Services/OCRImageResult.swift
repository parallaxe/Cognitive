import Foundation

struct OCRImageResult {
    struct RegionsItem {
        struct LinesItem {
            struct WordsItem {
                var boundingBox: String?
                var text: String?
            }
            var boundingBox: String?
            var words: [WordsItem]?
        }
        var boundingBox: String?
        var lines: [LinesItem]?
    }
    var language: String?
    var orientation: String?
    var regions: [RegionsItem]?
    var textAngle: Double?
}

extension OCRImageResult {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.textAngle = try Optional(jsonValue: dict["textAngle"]) { try Double(jsonValue: $0) }
        self.regions = try Optional(jsonValue: dict["regions"]) { try Array(jsonValue: $0) { try OCRImageResult.RegionsItem(jsonValue: $0) } }
        self.orientation = try Optional(jsonValue: dict["orientation"]) { try String(jsonValue: $0) }
        self.language = try Optional(jsonValue: dict["language"]) { try String(jsonValue: $0) }
    }
}

extension OCRImageResult.RegionsItem {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.boundingBox = try Optional(jsonValue: dict["boundingBox"]) { try String(jsonValue: $0) }
        self.lines = try Optional(jsonValue: dict["lines"]) { try Array(jsonValue: $0) { try OCRImageResult.RegionsItem.LinesItem(jsonValue: $0) } }
    }
}

extension OCRImageResult.RegionsItem.LinesItem {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.boundingBox = try Optional(jsonValue: dict["boundingBox"]) { try String(jsonValue: $0) }
        self.words = try Optional(jsonValue: dict["words"]) { try Array(jsonValue: $0) { try OCRImageResult.RegionsItem.LinesItem.WordsItem(jsonValue: $0) } }
    }
}

extension OCRImageResult.RegionsItem.LinesItem.WordsItem {
    init(jsonValue: AnyObject?) throws {
        guard let dict = jsonValue as? [NSObject: AnyObject] else {
            throw JsonParsingError.UnsupportedTypeError
        }
        self.boundingBox = try Optional(jsonValue: dict["boundingBox"]) { try String(jsonValue: $0) }
        self.text = try Optional(jsonValue: dict["text"]) { try String(jsonValue: $0) }
    }
}

func parseOCRImageResult(jsonValue: AnyObject?) throws -> OCRImageResult {
    return try OCRImageResult(jsonValue: jsonValue)
}
