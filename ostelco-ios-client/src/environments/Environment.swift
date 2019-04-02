//
//  Environment.swift
//  ostelco-ios-client
//
//  Created by mac on 10/30/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public enum PlistKey {
    case ServerURL
    case StripePublishableKey
    case Auth0ClientID
    case Auth0Domain
    case Auth0LogoURL
    case FreshchatAppID
    case FreshchatAppKey
    case AppleMerchantId
    case BugseeToken
    case JumioToken
    case JumioSecret
    case MyInfoURL
    case MyInfoClientID
    case MyInfoCallbackURL

    func value() -> String {
        switch self {
        case .ServerURL:
            return "server_url"
        case .StripePublishableKey:
            return "stripe_publishable_key"
        case .Auth0ClientID:
            return "auth0_client_id"
        case .Auth0Domain:
            return "auth0_domain"
        case .Auth0LogoURL:
            return "auth0_logo_url"
        case .FreshchatAppID:
            return "freshchat_app_id"
        case .FreshchatAppKey:
            return "freshchat_app_key"
        case .AppleMerchantId:
            return "apple_merchant_id"
        case .BugseeToken:
            return "bugsee_token"
        case .JumioToken:
            return "jumio_token"
        case .JumioSecret:
            return "jumio_secret"
        case .MyInfoURL:
            return "myinfo_url"
        case .MyInfoClientID:
            return "myinfo_client_id"
        case .MyInfoCallbackURL:
            return "myinfo_callback_url"
        }
    }
}

public struct Environment {

    fileprivate var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            }else {
                fatalError("Plist file not found")
            }
        }
    }
    public func configuration(_ key: PlistKey) -> String {
        var dictKey = ""
        switch key {
        case .ServerURL:
            dictKey = PlistKey.ServerURL.value()
        case .StripePublishableKey:
            dictKey = PlistKey.StripePublishableKey.value()
        case .Auth0ClientID:
            dictKey = PlistKey.Auth0ClientID.value()
        case .Auth0Domain:
            dictKey = PlistKey.Auth0Domain.value()
        case .Auth0LogoURL:
            dictKey = PlistKey.Auth0LogoURL.value()
        case .FreshchatAppID:
            dictKey = PlistKey.FreshchatAppID.value()
        case .FreshchatAppKey:
            dictKey = PlistKey.FreshchatAppKey.value()
        case .AppleMerchantId:
            dictKey = PlistKey.AppleMerchantId.value()
        case .BugseeToken:
            dictKey = PlistKey.BugseeToken.value()
        case .JumioToken:
            dictKey = PlistKey.JumioToken.value()
        case .JumioSecret:
            dictKey = PlistKey.JumioSecret.value()
        case .MyInfoURL:
            dictKey = PlistKey.MyInfoURL.value()
        case .MyInfoClientID:
            dictKey = PlistKey.MyInfoClientID.value()
        case .MyInfoCallbackURL:
            dictKey = PlistKey.MyInfoCallbackURL.value()
        }
        return (infoDict[dictKey] as! String).replacingOccurrences(of: "\\", with: "")
    }
}
