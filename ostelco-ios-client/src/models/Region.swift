//
//  Region.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

enum KycStatus: String, Codable {
    case APPROVED, REJECTED, PENDING
}

struct KYCStatusMap: Codable {
    let JUMIO: KycStatus?
    let MY_INFO: KycStatus?
    let NRIC_FIN: KycStatus?
    let ADDRESS_AND_PHONE_NUMBER: KycStatus?
}

struct Region: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
}

struct RegionResponse: Codable {
    let region: Region
    let status: KycStatus
    let simProfiles: [SimProfile]?
    let kycStatusMap: KYCStatusMap
}
