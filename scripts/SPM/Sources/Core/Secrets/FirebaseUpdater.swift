//
//  FirebaseUpdater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

struct FirebaseUpdater {
    enum KeyToUpdate: String, CaseIterable {
        case adUnitForBannerTest = "FIR_AD_UNIT_ID_FOR_BANNER_TEST"
        case apiKey = "FIR_API_KEY"
        case clientID = "FIR_CLIENT_ID"
        case databaseURL = "FIR_DATABASE_URL"
        case gcmSenderID = "FIR_GCM_SENDER_ID"
        case googleAppID = "FIR_GOOGLE_APP_ID"
        case projectID = "FIR_PROJECT_ID"
        case reversedClientID = "FIR_REVERSED_CLIENT_ID"
        case storageBucket = "FIR_STORAGE_BUCKET"
    }
    
    private static let plistFileName = "GoogleService-Info.plist"
    
    private static func outputFile(in sourceRoot: Folder) throws -> File {
        let appFolder = try sourceRoot.subfolder(named: "ostelco-ios-client")
        let supportingFilesFolder = try appFolder.subfolder(named: "SupportingFiles")
        return try supportingFilesFolder.file(named: self.plistFileName)
    }
    
    static func run(secrets: [String: String],
                    sourceRoot: Folder) throws {
        
        let firebaseSecrets = secrets.filter { (entry) in
            return KeyToUpdate(rawValue: entry.key) != nil
        }
        
        guard firebaseSecrets.count == KeyToUpdate.allCases.count else {
            // We're missing some stuff here.
            let missingKeys = KeyToUpdate.allCases
                // Missing keys are ones where no value is present
                .filter { secrets[$0.rawValue] == nil }
                // Map to the raw value of the key so it can be updated more easily in json
                .map { $0.rawValue }
            
            throw Secrets.Error.missingSecrets(keyNames: missingKeys)
        }
        
        let plistFile = try self.outputFile(in: sourceRoot)
        
        try firebaseSecrets.forEach { (entry) in
            try PlistUpdater.setValue(entry.value, for: entry.key, in: plistFile)
        }
        
        try PlistUpdater.save(file: plistFile)
    }
    
    static func reset(sourceRoot: Folder) throws {
        let file = try self.outputFile(in: sourceRoot)
    }
}
