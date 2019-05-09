//
//  EnvironmentUpdater.swift
//  Basic
//
//  Created by Ellen Shapiro on 4/9/19.
//

import Foundation
import Files

/// Updates the `Environment.plist` file.
struct EnvironmentUpdater {
    
    /// Required keys which should be provided in either a `secrets.json` file or in the CI environment.
    enum EnvironmentKey: String, CaseIterable, KeyToUpdate {
        case appleMerchantId = "apple_merchant_id"
        case firebaseProjectID = "firebase_project_id"
        case freshchatAppID = "freshchat_app_id"
        case freshchatAppKey = "freshchat_app_key"
        case jumioToken = "jumio_token"
        case jumioSecret = "jumio_secret"
        case myInfoURL = "myinfo_url"
        case myInfoClientID = "myinfo_client_id"
        case myInfoCallbackURL = "myinfo_callback_url"
        case serverURL = "server_url"
        case stripePublishableKey = "stripe_publishable_key"
        
        var jsonKey: String {
            switch self {
            case .firebaseProjectID:
                return "FIR_PROJECT_ID"
            default:
                return self.rawValue
            }
        }
        
        var plistKey: String {
            return self.rawValue
        }
        
        init?(jsonKey: String) {
            if jsonKey == EnvironmentKey.firebaseProjectID.jsonKey {
                self = .firebaseProjectID
            } else {
                self.init(rawValue: jsonKey)
            }
        }
    }
}

extension EnvironmentUpdater: SecretPlistUpdater {
    static var keyType: KeyToUpdate.Type {
        return EnvironmentKey.self
    }
    
    static var outputFileName: String {
        return "Environment.plist"
    }
}
