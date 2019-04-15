//
//  Auth0Updater.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files

/// Updates the `Auth0.plist` file.
struct Auth0Updater {
    
    /// Required keys which should be provided in either a `secrets.json` file or in the CI environment.
    enum Auth0Key: String, CaseIterable, KeyToUpdate {
        case clientID = "auth0_client_id"
        case domain = "auth0_domain"
        
        var jsonKey: String {
            return self.rawValue
        }
        
        var plistKey: String {
            switch self {
            case .domain:
                return "Domain"
            case .clientID:
                return "ClientId"
            }
        }
    }
}

extension Auth0Updater: SecretPlistUpdater {
    
    static var keyType: KeyToUpdate.Type {
        return Auth0Key.self
    }
    
    static var outputFileName: String {
        return "Auth0.plist"
    }
}
