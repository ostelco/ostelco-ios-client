//
//  Region.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public enum KycStatus: String, Codable {
    case APPROVED
    case REJECTED
    case PENDING
}

public struct KYCStatusMap: Codable {
    public let JUMIO: KycStatus?
    public let MY_INFO: KycStatus?
    public let NRIC_FIN: KycStatus?
    public let ADDRESS_AND_PHONE_NUMBER: KycStatus?
}

public struct Region: Codable {
    public let id: String
    public let name: String
}

public struct RegionResponse: Codable {
    public let region: Region
    public let status: KycStatus
    public let simProfiles: [SimProfile]?
    public let kycStatusMap: KYCStatusMap
}
