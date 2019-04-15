//
//  SecretPlistUpdater.swift
//  Basic
//
//  Created by Ellen Shapiro on 4/9/19.
//

import Foundation
import Files

/// A protocol representing a class which will update a single Plist file
protocol SecretPlistUpdater {
    
    /// The type of the KeyToUpdate. Should usually be a `CaseIterable` `String` enum.
    static var keyType: KeyToUpdate.Type { get }
    
    /// The name of the file where secrets should be output.
    static var outputFileName: String { get }
}

// MARK: - Default implementation
extension SecretPlistUpdater {
    
    static func outputFile(in sourceRoot: Folder) throws -> File {
        let appFolder = try sourceRoot.subfolder(named: "ostelco-ios-client")
        let supportingFilesFolder = try appFolder.subfolder(named: "SupportingFiles")
        return try supportingFilesFolder.file(named: self.outputFileName)
    }
    
    /// Resets the `Plist` updated by the conforming instance using git.
    /// NOTE: Only resets the specified output file, no other files will be reset.
    ///
    /// - Parameter sourceRoot: The main iOS project's source root
    static func reset(sourceRoot: Folder) throws {
        let plistFile = try self.outputFile(in: sourceRoot)
        try plistFile.resetToGitHEAD()
    }
    
    /// Updates the specified plist with the specified keys.
    ///
    /// - Parameters:
    ///   - secrets: An array of secrets to update
    ///   - sourceRoot: The main iOS project's source root
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
}
