//
//  JSONLoader.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

enum JSONLoaderError: Error {
    case couldntConvertToData
    case couldntConvertToProperDictionaryType
}

struct JSONLoader {
    
    static func loadJSONDictionary(from file: File) throws -> [String: AnyHashable] {
        let jsonString = try file.readAsString()
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw JSONLoaderError.couldntConvertToData
        }
        
        guard
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let typedDict = dict as? [String: AnyHashable] else {
                throw JSONLoaderError.couldntConvertToProperDictionaryType
        }
        
        return typedDict
    }
}
