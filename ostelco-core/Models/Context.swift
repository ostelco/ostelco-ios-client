//
//  Context.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct Context: Codable {
    public let customer: CustomerModel?
    public let regions: [RegionResponse]
    
    public func getRegion() -> RegionResponse? {
        return RegionResponse.getRegionFromRegionResponseArray(regions)
    }
}
