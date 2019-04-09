//
//  Auth0Updater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

struct Auth0Updater {
    enum JSONKeyToUpdate: String, CaseIterable {
        case clientID = "auth0_client_id"
        case domain = "auth0_domain"
        
        var plistKey: String {
            switch self {
            case .domain:
                return "Domain"
            case .clientID:
                return "ClientId"
            }
        }
    }
    
    private static let plistFileName = "Auth0.plist"

    private static func outputFile(in sourceRoot: Folder) throws -> File {
        let appFolder = try sourceRoot.subfolder(named: "ostelco-ios-client")
        let supportingFilesFolder = try appFolder.subfolder(named: "SupportingFiles")
        return try supportingFilesFolder.file(named: self.plistFileName)
    }
    
    static func run(secrets: [String: String],
                    sourceRoot: Folder) throws {
        let auth0Secrets = secrets.filter { (entry) in
            return JSONKeyToUpdate(rawValue: entry.key) != nil
        }
        
        guard auth0Secrets.count == JSONKeyToUpdate.allCases.count else {
            // We're missing some stuff here.
            let missingKeys = JSONKeyToUpdate.allCases
                // Missing keys are ones where no value is present
                .filter { secrets[$0.rawValue] == nil }
                // Map to the raw value of the key so it can be updated more easily in json
                .map { $0.rawValue }
            
            throw Secrets.Error.missingSecrets(keyNames: missingKeys)
        }
        
        let plistFile = try self.outputFile(in: sourceRoot)
        
        try auth0Secrets.forEach { (entry) in
            let key = JSONKeyToUpdate(rawValue: entry.key)!
            try PlistUpdater.setValue(entry.value, for: key.plistKey, in: plistFile)
        }
        
        try PlistUpdater.save(file: plistFile)
    }
    
    static func reset(sourceRoot: Folder) throws {
        let plistFile = try self.outputFile(in: sourceRoot)
        try plistFile.resetToGitHEAD()
    }
}
