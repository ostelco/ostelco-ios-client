//
//  EnvironmentUpdater.swift
//  Basic
//
//  Created by Ellen Shapiro on 4/9/19.
//

import Foundation
import Files

struct EnvironmentUpdater {
    enum EnvironmentKey: String, CaseIterable, KeyToUpdate {
        case appleMerchantId = "apple_merchant_id"
        case auth0ClientID = "auth0_client_id"
        case auth0Domain = "auth0_domain"
        case bugseeToken = "bugsee_token"
        case jumioToken = "jumio_token"
        case jumioSecret = "jumio_secret"
        case freshchatAppID = "freshchat_app_id"
        case freshchatAppKey = "freshchat_app_key"
        case myInfoURL = "myinfo_url"
        case myInfoClientID = "myinfo_client_id"
        case myInfoCallbackURL = "myinfo_callback_url"
        case serverURL = "server_url"
        case stripePublishableKey = "stripe_publishable_key"
        
        var jsonKey: String {
            return self.rawValue
        }
        
        var plistKey: String {
            return self.rawValue
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
