//
//  Secrets.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

struct Secrets {
    
    enum Error: Swift.Error {
        case couldNotAccessGitRoot
        case noSecretsFileOrSecrets(errorMessage: String)
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
    
    static func run(sourceRoot: Folder, forProd: Bool) throws {
        guard let gitRoot = sourceRoot.parent else {
            throw Error.couldNotAccessGitRoot
        }
        
        let secrets: [String: String]
        if self.localJSONExists(gitRoot: gitRoot, forProd: forProd) {
            print("Secrets file exists locally, loading from that...")
            secrets = try self.loadSecretsFromJSON(gitRoot: gitRoot, forProd: forProd)
        } else {
            print("No local secrets file, attempting to load from environment variables...")
            secrets = self.loadSecretsFromEnvironment()
            guard !secrets.isEmpty else {
                throw Error.noSecretsFileOrSecrets(errorMessage: "You don't have a secrets file or secrets set up in the environment - this ain't gonna work. Please make sure to set up secrets in Circle CI." )
            }
        }
        
        try FirebaseUpdater.run(secrets: secrets, sourceRoot: sourceRoot)
        try Auth0Updater.run(secrets: secrets, sourceRoot: sourceRoot)
    }
    
    private static func loadSecretsFromJSON(gitRoot: Folder, forProd: Bool) throws -> [String: String] {
        let secretsFolder = try gitRoot.subfolder(named: self.folderName)
        let iosFile = try secretsFolder.file(named: self.fileName(forProd: forProd))
        
        return try JSONLoader.loadStringJSON(from: iosFile)
    }
    
    private static func localJSONExists(gitRoot: Folder, forProd: Bool) -> Bool {
        do {
            let secretsFolder = try gitRoot.subfolder(named: self.folderName)
            return secretsFolder.containsFile(named: self.fileName(forProd: forProd))
        } catch {
            debugPrint("Error checking if export script exists: \(error)")
            return false
        }
    }
    
    
    private static func loadSecretsFromEnvironment() -> [String: String] {
        let envDict = ProcessInfo.processInfo.environment
        
        return envDict.filter { key, _ in
            return key.hasPrefix("FIR_")
        }
    }
}
