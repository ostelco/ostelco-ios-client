//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public enum SimProfileStatus: String, Codable {
    case AVAILABLE_FOR_DOWNLOAD
    case DOWNLOADED
    case INSTALLED
    case ENABLED
    case NOT_READY
}

public struct SimProfile: Codable, Equatable {
    public let eSimActivationCode: String
    public let alias: String
    public let iccId: String
    public let status: SimProfileStatus
    
    public init(eSimActivationCode: String,
                alias: String,
                iccId: String,
                status: SimProfileStatus) {
        self.eSimActivationCode = eSimActivationCode
        self.alias = alias
        self.iccId = iccId
        self.status = status
    }
}
