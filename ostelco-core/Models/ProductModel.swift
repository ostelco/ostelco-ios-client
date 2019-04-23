//
//  ProductModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct PresentationModel: Codable {
    public let label: String
    public let price: String
    public let isDefault: String?

    enum CodingKeys: String, CodingKey {
        case label = "productLabel"
        case price = "priceLabel"
        case isDefault
    }
}

public struct PriceModel: Codable {
    public let amount: Int
    public let currency: String

    enum CodingKeys: String, CodingKey {
        case amount, currency
    }
}

public struct ProductModel: Codable {
    public let sku: String
    public let presentation: PresentationModel
    public let price: PriceModel

    enum CodingKeys: String, CodingKey {
        case sku, presentation, price
    }
}
