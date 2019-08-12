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
    
    static var testApprovedRegionResponse: RegionDetailsFields {
        let region = RegionDetailsFields.Region(id: "1", name: "ApprovedRegion")
        return RegionDetailsFields(
            region: region,
            status: .approved,
            kycStatusMap: RegionDetailsFields.KycStatusMap(),
            simProfiles: nil
        )
    }
    
    static var testPendingRegionResponse: RegionDetailsFields {
        let region = RegionDetailsFields.Region(id: "2", name: "PendingRegion")
        return RegionDetailsFields(
            region: region,
            status: .pending,
            kycStatusMap: RegionDetailsFields.KycStatusMap(),
            simProfiles: nil
        )
    }
}
