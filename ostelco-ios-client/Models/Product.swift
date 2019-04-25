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

    @available(*, deprecated, message: "Construct a Product object from ProdctModel")
    init(name: String, label: String, amount: Decimal, country: String, currency: String, sku: String) {
        self.name = name
        self.label = label
        self.amount = amount
        self.country = country
        self.currency = currency
        self.sku = sku
    }

    init(from: ProductModel, countryCode: String) {
        name = from.presentation.label
        label = "Buy \(from.presentation.label) for \(from.presentation.price)"
        amount = Decimal(from.price.amount)
        country = countryCode
        currency = from.price.currency
        sku = from.sku
    }
}
