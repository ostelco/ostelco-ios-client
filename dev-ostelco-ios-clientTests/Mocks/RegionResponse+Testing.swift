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
    
    static var testApprovedRegionResponse: PrimeGQL.RegionDetailsFragment {
        let region = PrimeGQL.RegionDetailsFragment.Region(id: "1", name: "ApprovedRegion")
        return PrimeGQL.RegionDetailsFragment(
            region: region,
            status: .approved,
            kycStatusMap: PrimeGQL.RegionDetailsFragment.KycStatusMap(),
            simProfiles: nil
        )
    }
    
    static var testPendingRegionResponse: PrimeGQL.RegionDetailsFragment {
        let region = PrimeGQL.RegionDetailsFragment.Region(id: "2", name: "PendingRegion")
        return PrimeGQL.RegionDetailsFragment(
            region: region,
            status: .pending,
            kycStatusMap: PrimeGQL.RegionDetailsFragment.KycStatusMap(),
            simProfiles: nil
        )
    }
}
