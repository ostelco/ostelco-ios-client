//
//  Environment.swift
//  ostelco-ios-client
//
//  Created by mac on 10/30/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public enum PlistKey: String {
    case ServerURL = "server_url"
    case StripePublishableKey = "stripe_publishable_key"
    case Auth0ClientID = "auth0_client_id"
    case Auth0Domain = "auth0_domain"
    case FreshchatAppID = "freshchat_app_id"
    case FreshchatAppKey = "freshchat_app_key"
    case AppleMerchantId = "apple_merchant_id"
    case JumioToken = "jumio_token"
    case JumioSecret = "jumio_secret"
    case MyInfoURL = "myinfo_url"
    case MyInfoClientID = "myinfo_client_id"
    case MyInfoCallbackURL = "myinfo_callback_url"
}

public struct Environment {
    fileprivate var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            } else {
                fatalError("Plist file not found")
            }
        }
    }
    public func configuration(_ key: PlistKey) -> String {
        return (infoDict[key.rawValue] as! String).replacingOccurrences(of: "\\", with: "")
    }
}
