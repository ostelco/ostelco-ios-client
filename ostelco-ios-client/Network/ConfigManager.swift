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

func dataToStringArray(data: Data) -> [String]? {
    do {
        debugPrint(data)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        debugPrint(json)
        return json as? [String]
    } catch {
        ApplicationErrors.log(error)
        return nil
    }
}

#warning("Create test that fetches all values from remote config to verify that the default values exist in RemoteConfigDefaults.plist")
#warning("Validate remote data after fetching before activating the new values.")
final class ConfigManager {
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let expirationDuration: TimeInterval
    
    static let shared = ConfigManager()
    
    var welcomeMessage: String {
        return remoteConfig["welcome_message"].stringValue!
    }
    
    var enforceLocationCheckForRegions: [String] {
        let data = remoteConfig["enforce_location_check_for_regions"].dataValue
        debugPrint(data)
        if let ret = dataToStringArray(data: data) {
            return ret
        }
        // TODO: This is not a good default value (and this is only used as an example), it's probably better to always enforce location check if we fail to fetch data from remote config. Though data from remote config should be validated both on server side (can set up validation rules on data), but that has room for errors, so we should also check the values after we fetch before we activate. It's probably best to store the values inside ConfigManager in separate variables, instead of fetching directly from RemoteConfig, that way we can validate each individual value after fetching, then only storing if the new value is valid. Thus keeping the old value, which assumably is valid, as long as we also make sure that the default values in RemoteConfigDefaults.plist are valid values and that RemoteConfigDefaults.plist contains all possible values. One way to enforce the last point could be to create an enum of allowed values to fetch, and have a test case which iterates over all enum values and makes sure that the program does not crash and / or that the value is set
        // It's possible to fetch out default values, this could be used as an alternative if the server value is invalid
        /*
        let data2 = remoteConfig.defaultValue(forKey: "enforce_location_check_for_regions", namespace: nil)?.dataValue
        debugPrint(data2)
        remoteConfig.defaultValue(forKey: "enforce_location_check_for_regions", namespace: nil)?.stringValue
        if let ret = dataToStringArray(data: data) {
            return ret
        }
        */
        return []
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
