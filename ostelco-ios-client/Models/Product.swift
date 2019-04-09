//
//  Product.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

public class Product {
    let name: String
    let amount: Decimal
    let currency: String
    let country: String
    let sku: String

    init(name: String, amount: Decimal, country: String, currency: String, sku: String) {
        self.name = name
        self.amount = amount
        self.country = country
        self.currency = currency
        self.sku = sku
    }
}
