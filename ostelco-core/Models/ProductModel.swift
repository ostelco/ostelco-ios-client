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

extension PriceModel {
    public init(gqlData data: PrimeGQL.ProductFragment.Price) {
        self.amount = data.amount
        self.currency = data.currency
    }
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

extension ProductModel {
    public init(gqlData data: PrimeGQL.ProductFragment) {
        self.sku = data.sku
        self.price = PriceModel(gqlData: data.price)
        self.presentation = PresentationModel(label: data.presentation?.productLabel ?? "", price: data.presentation?.priceLabel ?? "", taxLabel: data.presentation?.taxLabel, tax: data.presentation?.tax, subTotalLabel: data.presentation?.subTotalLabel, subTotal: data.presentation?.subTotal, payeeLabel: data.presentation?.payeeLabel)
        
        if let productClass = data.properties?.productClass {
            self.properties = ["productClass": productClass]
        } else {
            self.properties = [:]
        }
    }
}
