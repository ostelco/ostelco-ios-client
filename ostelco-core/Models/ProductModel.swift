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
    public let taxLabel: String?
    public let tax: String?
    public let subTotalLabel: String?
    public let subTotal: String?
    public let payeeLabel: String?

    enum CodingKeys: String, CodingKey {
        case label = "productLabel"
        case price = "priceLabel"
        case taxLabel
        case tax
        case subTotalLabel
        case subTotal
        case payeeLabel
    }
}

public struct PriceModel: Codable {
    public let amount: Int
    public let currency: String
}

public struct ProductModel: Codable {
    public let sku: String
    public let presentation: PresentationModel
    public let price: PriceModel
    public let properties: [String: String]

    public var type: String {
        if let productClass = properties["productClass"] {
            return productClass.lowercased()
        }
        // default type is simple_data
        return "simple_data"
    }
}
