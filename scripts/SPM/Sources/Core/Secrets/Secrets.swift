//
//  Secrets.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

/// A struct to contain grabbing and/or resetting all secrets.
struct Secrets {
    
    /// Errors which can occur when generating secrets.
    ///
    /// - missingSecrets: Some secrets were missing from either `secrets.json` or the environment.
    ///                   Parameter is an array of the missing secret keys.
    enum Error: Swift.Error {
        case missingSecrets(keyNames: [String])
    }
    
    private static let folderName = ".secrets"
    
    private static func fileName(forProd: Bool) -> String {
        if forProd {
            return "ios_secrets_prod.json"
        } else {
            return "ios_secrets_dev.json"
        }
    }
    
    /// Takes secrets from either JSON or the environment and puts them into the appropriate plist files.
    ///
    /// - Parameters:
    ///   - sourceRoot: The main iOS project's source root
    ///   - forProd: True if the production values should be used, false if the dev values should be used.
    static func run(sourceRoot: Folder, forProd: Bool) throws {
        let secrets: [String: AnyHashable]
        if self.localJSONExists(sourceRoot: sourceRoot, forProd: forProd) {
            print("Secrets file exists locally, loading from that...")
            secrets = try self.loadSecretsFromJSON(sourceRoot: sourceRoot, forProd: forProd)
        } else {
            print("No local secrets file, attempting to load from environment variables...")
            secrets = ProcessInfo.processInfo.environment
        }
        
        try FirebaseUpdater.run(secrets: secrets, sourceRoot: sourceRoot)
        try EnvironmentUpdater.run(secrets: secrets, sourceRoot: sourceRoot)
    }
    
    /// Resets any plist files which were changed.
    ///
    /// - Parameter sourceRoot: The main iOS project's source root
    static func reset(sourceRoot: Folder) throws {
        try FirebaseUpdater.reset(sourceRoot: sourceRoot)
        try EnvironmentUpdater.reset(sourceRoot: sourceRoot)
    }
    
    private static func loadSecretsFromJSON(sourceRoot: Folder, forProd: Bool) throws -> [String: AnyHashable] {
        let secretsFolder = try sourceRoot.subfolder(named: self.folderName)
        let iosFile = try secretsFolder.file(named: self.fileName(forProd: forProd))
        
        return try JSONLoader.loadJSONDictionary(from: iosFile)
    }
    
    private static func localJSONExists(sourceRoot: Folder, forProd: Bool) -> Bool {
        do {
            let secretsFolder = try sourceRoot.subfolder(named: self.folderName)
            return secretsFolder.containsFile(named: self.fileName(forProd: forProd))
        } catch {
            debugPrint("Error checking if export script exists: \(error)")
            return false
        }
    }
}
