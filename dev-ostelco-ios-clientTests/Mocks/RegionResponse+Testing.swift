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
    
    static var testApprovedRegionResponse: RegionDetailsFragment {
        let region = RegionDetailsFragment.Region(id: "1", name: "ApprovedRegion")
        return RegionDetailsFragment(
            region: region,
            status: .approved,
            kycStatusMap: RegionDetailsFragment.KycStatusMap(),
            simProfiles: nil
        )
    }
    
    static var testPendingRegionResponse: RegionDetailsFragment {
        let region = RegionDetailsFragment.Region(id: "2", name: "PendingRegion")
        return RegionDetailsFragment(
            region: region,
            status: .pending,
            kycStatusMap: RegionDetailsFragment.KycStatusMap(),
            simProfiles: nil
        )
    }
}
