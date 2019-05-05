//
//  Context.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

struct Context: Codable {
    let customer: CustomerModel?
    let regions: [RegionResponse]
    
    func getRegion() -> RegionResponse? {
        return RegionResponse.getRegionFromRegionResponseArray(regions)
    }
}
