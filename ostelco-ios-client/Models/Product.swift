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
    let taxLabel: String
    let tax: Decimal
    let subTotalLabel: String
    let subTotal: Decimal
    let payeeLabel: String

    init(from: ProductFields, countryCode: String) {
        self.name = "\(from.presentation.productLabel) of Data"
        self.label = "Buy \(from.presentation.productLabel) for \(from.presentation.priceLabel)"
        self.amount = Decimal(from.price.amount)
        self.country = countryCode
        self.currency = from.price.currency
        self.sku = from.sku
        self.type = from.properties.productClass?.lowercased() ?? "simple_data"
        self.taxLabel = from.presentation.taxLabel ?? ""
        self.tax = Decimal(string: from.presentation.tax ?? "" ) ?? 0
        self.subTotalLabel = from.presentation.subTotalLabel ?? ""
        self.subTotal = Decimal(string: from.presentation.subTotal ?? "") ?? 0
        self.payeeLabel = from.presentation.payeeLabel ?? ""
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
        - Tax Label: \(self.taxLabel)
        - Tax: \(self.tax)
        - SubTotal Label: \(self.subTotalLabel)
        - SubTotal: \(self.subTotal)
        - Payee Label: \(self.payeeLabel)
        """
    }
}
