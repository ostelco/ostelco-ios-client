//
//  SecretPlistUpdater.swift
//  Basic
//
//  Created by Ellen Shapiro on 4/9/19.
//

import Foundation
import Files

protocol KeyToUpdate {
    var rawValue: String { get }
    init?(rawValue: String)
    init?(jsonKey: String)

    var jsonKey: String { get }
    var plistKey: String { get }
    static var count: Int { get }
    
    static func missingJSONKeys(in jsonDictionary: [String: AnyHashable]) -> [String]
}

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

protocol SecretPlistUpdater {
    static var keyType: KeyToUpdate.Type { get }
    static var outputFileName: String { get }
}

extension SecretPlistUpdater {
    
    static func outputFile(in sourceRoot: Folder) throws -> File {
        let appFolder = try sourceRoot.subfolder(named: "ostelco-ios-client")
        let supportingFilesFolder = try appFolder.subfolder(named: "SupportingFiles")
        return try supportingFilesFolder.file(named: self.outputFileName)
    }
    
    static func run(secrets: [String: AnyHashable],
                    sourceRoot: Folder) throws {
        let relevantSecrets = secrets.filter { (entry) in
            return self.keyType.init(jsonKey: entry.key) != nil
        }
        
        guard relevantSecrets.count == self.keyType.count else {
            let missingKeys = self.keyType.missingJSONKeys(in: secrets)
            throw Secrets.Error.missingSecrets(keyNames: missingKeys)
        }
        
        let outputFile = try self.outputFile(in: sourceRoot)
        try relevantSecrets.forEach { (entry) in
            let key = self.keyType.init(jsonKey: entry.key)!
            try PlistUpdater.setValue(entry.value, for: key.plistKey, in: outputFile)
        }
        
        try PlistUpdater.save(file: outputFile)
    }
    
    static func reset(sourceRoot: Folder) throws {
        let plistFile = try self.outputFile(in: sourceRoot)
        try plistFile.resetToGitHEAD()
    }
}
