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
    
    func value() -> String {
        switch self {
        case .ServerURL:
            return "server_url"
        case .StripePublishableKey:
            return "stripe_publishable_key"
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
            break;
        case .StripePublishableKey:
            dictKey = PlistKey.StripePublishableKey.value()
            break;
        }
        return (infoDict[dictKey] as! String).replacingOccurrences(of: "\\", with: "")
    }
}
