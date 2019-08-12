//
//  Context.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct Context {
    public let customer: CustomerFields?
    public let regions: [RegionDetailsFields]
    
    public init(customer: CustomerFields?, regions: [RegionDetailsFields]) {
        self.customer = customer
        self.regions = regions
    }
    
    public init(customer: CustomerModel, regions: [RegionDetailsFields]) {
        self.customer = CustomerFields.init(id: customer.id, contactEmail: customer.email, nickname: customer.analyticsId, referralId: customer.referralId, analyticsId: customer.analyticsId)
        self.regions = regions
    }
    
    public init(customer: CustomerModel?, regions: [RegionResponse]) {
        self.customer = customer?.toGraphQLModel()
        self.regions = regions.map({ $0.getGraphQLModel() })
    }
    
    public func getRegion() -> RegionDetailsFields? {
        return RegionResponse.getRegionFromRegionResponseArray(regions)
    }
}

extension CustomerQuery.Data.Customer {
    public func getRegion() -> RegionDetailsFields? {
        return RegionResponse.getRegionFromRegionResponseArray(regions!.map{$0.fragments.regionDetailsFields})
    }
    
    public func toLegacyModel() -> Context {
        return Context(customer: CustomerModel(gqlCustomer: self.fragments.customerFields), regions: regions!.map{$0.fragments.regionDetailsFields})
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
