//
//  BundleModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct BundleModel: Codable {

    public let id: String
    public let balance: Int64
    
    public init(gqlData: PrimeGQL.GetBundlesQuery.Data.Context.Bundle) {
        self.id = gqlData.id
        self.balance = gqlData.balance
    }
}
