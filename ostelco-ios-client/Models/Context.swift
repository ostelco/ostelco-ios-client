//
//  Context.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

// TODO: Use Region struct from Region.swift when feature/ekyc-api-integration branch is merged into develop

func getRegionFromRegionResponseArray(_ regionResponses: [RegionResponse]) -> RegionResponse? {
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

struct Context: Codable {
    let customer: CustomerModel?
    let regions: [RegionResponse]
    
    enum CodingKeys: String, CodingKey {
        case customer, regions
    }
    
    func getRegion() -> RegionResponse? {
        return getRegionFromRegionResponseArray(regions)
    }
}
