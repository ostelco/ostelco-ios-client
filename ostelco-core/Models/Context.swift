//
//  Context.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct Context {
    public let customer: CustomerModel?
    public let regions: [PrimeGQL.RegionDetailsFragment]
    
    public init(customer: CustomerModel?, regions: [PrimeGQL.RegionDetailsFragment]) {
        self.customer = customer
        self.regions = regions
    }
    
    public init(customer: CustomerModel?, regions: [RegionResponse]) {
        self.customer = customer
        self.regions = regions.map({ $0.getGraphQLModel() })
    }
    
    public func getRegion() -> PrimeGQL.RegionDetailsFragment? {
        return RegionResponse.getRegionFromRegionResponseArray(regions)
    }
}

public struct DecodableContext: Decodable {
    public let customer: CustomerModel?
    public let regions: [RegionResponse]
    
    public init(customer: CustomerModel?, regions: [RegionResponse]) {
        self.customer = customer
        self.regions = regions
    }
    
    public func toContext() -> Context {
        return Context(customer: customer, regions: regions)
    }
}
