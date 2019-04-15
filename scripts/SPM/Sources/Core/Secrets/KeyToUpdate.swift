//
//  KeyToUpdate.swift
//  Basic
//
//  Created by Ellen Shapiro on 4/15/19.
//

import Foundation

/// Represents a key to update from a `secrets.json` file or the CI environment.
/// NOTE: Most of the time this should be a `String` enum conforming to `CaseIterable`. 
protocol KeyToUpdate {
    
    // MARK: Helpers to allow easy use of `String` enums
    var rawValue: String { get }
    init?(rawValue: String)
    
    /// Initializer in case the JSON key and the `rawValue` are not identical.
    init?(jsonKey: String)
    
    /// The JSON key to use to pull values out of a JSON file or the CI environment
    var jsonKey: String { get }
    
    /// The key to use to write secrets to a `plist`
    var plistKey: String { get }
    
    /// How many keys are there?
    static var count: Int { get }
    
    /// Checks a dictionary to validate all keys in the current enum are present.
    ///
    /// - Parameter jsonDictionary: The dictionary to check.
    /// - Returns: An array of keys which do not have values in the passed-in dictionary. Will be empty if no keys are missing.
    static func missingJSONKeys(in jsonDictionary: [String: AnyHashable]) -> [String]
}


// MARK: - CaseIterable default implementations
extension KeyToUpdate where Self: CaseIterable {
    
    init?(jsonKey: String) {
        self.init(rawValue: jsonKey)
    }
    
    static var count: Int {
        return self.allCases.count
    }
    
    static func missingJSONKeys(in jsonDictionary: [String: AnyHashable]) -> [String] {
        let missing = self.allCases
            // Missing keys are ones where no value is present
            .filter { jsonDictionary[$0.jsonKey] == nil }
            // Return the JSON key which is missing, not the raw object.
            .map { $0.jsonKey }
        
        return missing
    }
}
