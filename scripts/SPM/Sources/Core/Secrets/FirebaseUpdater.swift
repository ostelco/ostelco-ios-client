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
        case adUnitForBannerTest = "AD_UNIT_ID_FOR_BANNER_TEST"
        case adUnitForInterstitialTest = "AD_UNIT_ID_FOR_INTERSTITIAL_TEST"
        case apiKey = "API_KEY"
        case bundleID = "BUNDLE_ID"
        case clientID = "CLIENT_ID"
        case databaseURL = "DATABASE_URL"
        case gcmSenderID = "GCM_SENDER_ID"
        case googleAppID = "GOOGLE_APP_ID"
        case projectID = "PROJECT_ID"
        case reversedClientID = "REVERSED_CLIENT_ID"
        case storageBucket = "STORAGE_BUCKET"
    }
    
    private static let plistFileName = "GoogleService-Info.plist"
    
    static func outputFile(in sourceRoot: Folder) throws -> File {
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
        try file.resetToGitHEAD()
    }
}
