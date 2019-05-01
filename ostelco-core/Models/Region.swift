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
    
    /// Testing initializer
    init(jumio: KycStatus? = nil,
         myInfo: KycStatus? = nil,
         nricFin: KycStatus? = nil,
         addressPhone: KycStatus? = nil) {
        self.JUMIO = jumio
        self.MY_INFO = myInfo
        self.NRIC_FIN = nricFin
        self.ADDRESS_AND_PHONE_NUMBER = addressPhone
    }
}

public struct Region: Codable {
    public let id: String
    public let name: String
    
    /// Testing initializer
    init(id: String,
         name: String) {
        self.id = id
        self.name = name
    }
}

public struct RegionResponse: Codable {
    public let region: Region
    public let status: KycStatus
    public let simProfiles: [SimProfile]?
    public let kycStatusMap: KYCStatusMap
    
    /// Testing initializer
    init(region: Region,
         status: KycStatus,
         simProfiles: [SimProfile]?,
         kycStatusMap: KYCStatusMap) {
        self.region = region
        self.status = status
        self.simProfiles = simProfiles
        self.kycStatusMap = kycStatusMap
    }
    
    public static func getRegionFromRegionResponseArray(_ regionResponses: [RegionResponse]) -> RegionResponse? {
        if let approvedRegion = regionResponses.first(where: { $0.status == .APPROVED }) {
            // Hooray, at least one region has been approved!
            return approvedRegion
        } else if let rejectedRegion = regionResponses.last(where: { $0.status == .REJECTED }) {
            // Boo, at least one region has been rejected.
            return rejectedRegion
        } else {
            // Return the last response, which is either nil or .PENDING
            return regionResponses.last
        }
    }
}
