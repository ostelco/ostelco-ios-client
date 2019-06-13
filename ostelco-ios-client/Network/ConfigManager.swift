//
//  ConfigManager.swift
//  ostelco-ios-client
//
//  Created by mac on 6/13/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import PromiseKit

#warning("Create test that fetches all values from remote config to verify that the default values exist in RemoteConfigDefaults.plist")
final class ConfigManager {
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let expirationDuration: TimeInterval
    
    static let shared = ConfigManager()
    
    var welcomeMessage: String {
        return remoteConfig["welcome_message"].stringValue!
    }
    
    enum ConfigError: LocalizedError {
        case failedWithoutError
        
        var localizedDescription: String {
            switch self {
            case .failedWithoutError:
                return "Failed to fetch remote config from firebase and firebase did not return any error"
            }
        }
    }
    
    private init() {
        #if DEBUG
        // Enabling developer mode disables caching so you will always get the latest values
        expirationDuration = 0
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        #else
        // An app can fetch a maximum of 5 times in a 60 minute window before the SDK begins to throttle
        // and returns FIRRemoteConfigFetchStatusThrottled. (Check the firebase documentation for the latest documentation)
        expirationDuration = 3600
        #endif
        
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    func fetch() -> Promise<Bool> {
        return Promise { seal in
            debugPrint("Fetching remote config values from firebase with expiration duration \(expirationDuration) seconds")
            remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { status, error in
                if status == .success {
                    debugPrint("Activate newly fetched remote config values")
                    self.remoteConfig.activateFetched()
                    seal.fulfill(true)
                } else {
                    ApplicationErrors.assertAndLog("Failed to fetch remote config, got error: \(error?.localizedDescription ?? "No error available.")")
                    seal.reject(error ?? ConfigError.failedWithoutError)
                }
            }
        }
        
    }
}
