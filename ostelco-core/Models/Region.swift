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
    
    public static func getRegionFromRegionResponseArray(_ regionResponses: [RegionResponse]) -> RegionResponse? {
        var ret: RegionResponse?
        
        var hasRejectedStatus = false
        var hasApprovedStatus = false
        
        for region in regionResponses {
            switch region.status {
            case .PENDING:
                if !hasRejectedStatus && !hasApprovedStatus {
                    ret = region
                }
            case .REJECTED:
                if !hasApprovedStatus {
                    ret = region
                }
                hasRejectedStatus = true
            case .APPROVED:
                ret = region
                hasApprovedStatus = true
            }
            
            if hasApprovedStatus {
                break
            }
        }
        
        return ret
    }
}
