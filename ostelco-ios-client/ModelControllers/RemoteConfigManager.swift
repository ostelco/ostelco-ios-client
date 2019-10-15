//
//  RemoteConfigManager.swift
//  ostelco-ios-client
//
//  Created by mac on 10/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Firebase

class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!
    private let expirationDuration = 3600
    
    var regionGroups: [RegionGroup] {
        // swiftlint:disable:next force_cast
        return RemoteConfigParameters.regionGroups.value as! [RegionGroup]
    }
    
    var countryCodeAndRegionCodes: [CountryCodeAndRegionCodes] {
        // swiftlint:disable:next force_cast
        return RemoteConfigParameters.countryCodeToRegionCodes.value as! [CountryCodeAndRegionCodes]
    }
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
    }
    
    func fetch() {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                // TODO: This is the place to do validation on fetched values before activating, if that's needed
                self.remoteConfig.activate(completionHandler: nil)
            } else {
                ApplicationErrors.assertAndLog("Failed to fetch remote config: \(error.debugDescription)")
            }
        }
    }
}

struct CountryCodeAndRegionCodes: Codable {
    let countryCode: String
    let regionCodes: [String]
}

struct RegionGroup: Codable {
    let name: String
    let description: String
    let backgroundColor: RegionGroupBackgroundColor
    let isPreview: Bool
    let countryCodes: [String]
}

enum RemoteConfigParameters: String, CaseIterable {
    case countryCodeToRegionCodes = "country_code_to_region_codes"
    case regionGroups = "region_groups"
}

// Ref: https://diamantidis.github.io/2019/06/30/firebase-remote-config-iOS-implementation
extension RemoteConfigParameters {

    var value: Codable? {
        switch self {
        case .countryCodeToRegionCodes:
            do {
                return try self.toCodable().get() as [CountryCodeAndRegionCodes]
            } catch {
                ApplicationErrors.assertAndLog("Failed to convert remote config key \(self.rawValue) to Codable. Returning default value.")
                return [] as [CountryCodeAndRegionCodes]
            }
        case .regionGroups:
            do {
              return try self.toCodable().get() as [RegionGroup]
            } catch {
                ApplicationErrors.assertAndLog("Failed to convert remote config key \(self.rawValue) to Codable. Returning default value.")
                return [] as [RegionGroup]
            }
        }
    }

    private func toCodable<T: Codable>() -> Result<T, Error> {
        let data = RemoteConfig.remoteConfig().configValue(forKey: self.rawValue).dataValue
         return Result { try JSONDecoder().decode(T.self, from: data) }
    }
}
