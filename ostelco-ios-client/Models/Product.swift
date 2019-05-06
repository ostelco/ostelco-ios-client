//
//  Product.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//
import ostelco_core

public class Product {
    let name: String
    let label: String
    let amount: Decimal
    let currency: String
    let country: String
    let sku: String
    let type: String

    init(from: ProductModel, countryCode: String) {
        self.name = "\(from.presentation.label) of Data"
        self.label = "Buy \(from.presentation.label) for \(from.presentation.price)"
        self.amount = Decimal(from.price.amount)
        self.country = countryCode
        self.currency = from.price.currency
        self.sku = from.sku
        self.type = from.type
    }
}

extension Product: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        - Name: \(self.name)
        - Amount: \(self.amount)
        - Currency: \(self.currency)
        - Country: \(self.country)
        - SKU: \(self.sku)
        """
    }
}
