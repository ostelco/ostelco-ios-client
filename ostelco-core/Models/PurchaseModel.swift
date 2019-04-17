//
//  PurchaseModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct PurchaseModel: Codable {
    let id: String
    let timestamp: Int64
    let product: ProductModel
}
