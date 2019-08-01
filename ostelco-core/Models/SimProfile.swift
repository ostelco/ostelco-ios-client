//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public enum SimProfileStatusLegacy: String, Codable {
    case AVAILABLE_FOR_DOWNLOAD
    case DOWNLOADED
    case INSTALLED
    case ENABLED
    case NOT_READY
}

extension SimProfileStatusLegacy {
    func getGraphQLModel() -> SimProfileStatus {
        return SimProfileStatus(rawValue: self.rawValue)!
    }
}

public struct SimProfileLegacy: Codable, Equatable {
    public let eSimActivationCode: String
    public let alias: String
    public let iccId: String
    public let status: SimProfileStatusLegacy
    
    public init(eSimActivationCode: String,
                alias: String,
                iccId: String,
                status: SimProfileStatusLegacy) {
        self.eSimActivationCode = eSimActivationCode
        self.alias = alias
        self.iccId = iccId
        self.status = status
    }
}

extension SimProfileLegacy {
    public init(gqlSimProfile: SimProfileFields) {
        let status = SimProfileStatusLegacy(rawValue: gqlSimProfile.status.rawValue)!
        self.init(eSimActivationCode: gqlSimProfile.eSimActivationCode,
                  alias: gqlSimProfile.alias,
                  iccId: gqlSimProfile.iccId,
                  status: status
        )
    }
    
    public func getGraphQLModel() -> RegionDetailsFragment.SimProfile {
        return RegionDetailsFragment.SimProfile(eSimActivationCode: eSimActivationCode, alias: alias, iccId: iccId, status: status.getGraphQLModel())
    }
}
