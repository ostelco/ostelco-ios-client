//
//  RegionResponse+Testing.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
@testable import ostelco_core

extension RegionResponse {
    
    static var testApprovedRegionResponse: RegionResponse {
        let region = Region(id: "1", name: "ApprovedRegion")
        return RegionResponse(region: region,
                              status: .APPROVED,
                              simProfiles: nil,
                              kycStatusMap: KYCStatusMap())
    }
    
    static var testPendingRegionResponse: RegionResponse {
        let region = Region(id: "2", name: "PendingRegion")
        return RegionResponse(region: region,
                              status: .PENDING,
                              simProfiles: nil,
                              kycStatusMap: KYCStatusMap())
    }
    
    static var testRejectedRegionRepsonse: RegionResponse {
        let region = Region(id: "3", name: "RejectedRegion")
        return RegionResponse(region: region,
                              status: .REJECTED,
                              simProfiles: nil,
                              kycStatusMap: KYCStatusMap())
    }
}
