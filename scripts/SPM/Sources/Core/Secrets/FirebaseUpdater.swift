//
//  FirebaseUpdater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

struct FirebaseUpdater {
    enum FirebaseKey: String, CaseIterable, KeyToUpdate {
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
        
        var jsonKey: String {
            return "FIR_\(self.rawValue)"
        }
        
        var plistKey: String {
            return self.rawValue
        }
        
        init?(jsonKey: String) {
            let droppedPrefix = jsonKey.replacingOccurrences(of: "FIR_", with: "")
            self.init(rawValue: droppedPrefix)
        }
    }
}

extension FirebaseUpdater: SecretPlistUpdater {
    static var keyType: KeyToUpdate.Type {
        return FirebaseKey.self
    }
    
    static var outputFileName: String {
        return "GoogleService-Info.plist"
    }
}
