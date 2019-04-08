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
    
    static func loadStringJSON(from file: File) throws -> [String: String] {
        let jsonString = try file.readAsString()
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw JSONLoaderError.couldntConvertToData
        }
        
        guard
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let stringDict = dict as? [String: String] else {
                throw JSONLoaderError.couldntConvertToProperDictionaryType
        }
        
        return stringDict
    }
}
