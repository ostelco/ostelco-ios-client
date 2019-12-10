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
    case FreshchatAppID = "freshchat_app_id"
    case FreshchatAppKey = "freshchat_app_key"
    case AppleMerchantId = "apple_merchant_id"
    case JumioToken = "jumio_token"
    case JumioSecret = "jumio_secret"
    case MyInfoURL = "myinfo_url"
    case MyInfoClientID = "myinfo_client_id"
    case MyInfoCallbackURL = "myinfo_callback_url"
    case FirebaseProjectID = "firebase_project_id"
}

public class EnvironmentPlist {
    
    private lazy var infoDict: [String: AnyHashable] = {
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard
            let plistURL = Bundle.main.url(forResource: "Environment", withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format),
            let infoDict = plist as? [String: AnyHashable] else {
                fatalError("Couldn't load environment plist!")
        }
        
        return infoDict
    }()
    
    public func configuration(_ key: PlistKey) -> String {
        guard let value = self.infoDict[key.rawValue] as? String else {
            ApplicationErrors.assertAndLog("Could not find string value for \(key.rawValue) in Environment dictionary!")
            return ""
        }
        
        return value
    }
}
