//
//  PurchaseModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct PurchaseModel: Codable {
    public let id: String
    public let timestamp: Int64
    public let product: ProductModel
}

extension PurchaseModel {
    public init(gqlData data: PrimeGQL.GetPurchasesQuery.Data.Context.Purchase) {
        self.id = data.id
        self.timestamp = data.timestamp
        self.product = ProductModel(gqlData: data.product.fragments.productFragment)
    }
}
