//
//  Product.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//
import ostelco_core
import Stripe

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

    init(from: PrimeGQL.ProductFragment, countryCode: String) {
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

extension Product {
    // Stripe (& Prime) expects amounts to be provided in currency's smallest unit.
    // https://stripe.com/docs/currencies#zero-decimal
    // https://github.com/stripe/stripe-ios/blob/v15.0.1/Stripe/NSDecimalNumber%2BStripe_Currency.m
    
    var stripeAmount: NSDecimalNumber {
        convertStripeToNormalCurrency(amount: self.amount, currency: self.currency)
    }
    
    var stripeTax: NSDecimalNumber {
        convertStripeToNormalCurrency(amount: self.tax, currency: self.currency)
    }
    
    var stripeSubTotal: NSDecimalNumber {
        convertStripeToNormalCurrency(amount: self.subTotal, currency: self.currency)
    }
    
    var stripePaymentRequest: PKPaymentRequest {
        let merchantIdentifier = Environment().configuration(.AppleMerchantId)
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: country, currency: currency)
         // canMakePayments()
         
         paymentRequest.paymentSummaryItems = [
             PKPaymentSummaryItem(label: subTotalLabel, amount: stripeSubTotal),
             PKPaymentSummaryItem(label: taxLabel, amount: stripeTax),
             PKPaymentSummaryItem(label: payeeLabel, amount: stripeAmount)
         ]
        
        return paymentRequest
    }
    
    var canSubmitPaymentRequest: Bool {
        return Stripe.canSubmitPaymentRequest(stripePaymentRequest)
    }
    
    private func convertStripeToNormalCurrency(amount: Decimal, currency: String) -> NSDecimalNumber {
        let zeroDecimalCountries = [
            "bif", "clp", "djf", "gnf", "jpy",
            "kmf", "krw", "mga", "pyg", "rwf",
            "vnd", "vuv", "xaf", "xof", "xpf"
        ]
        let amountInCurrency = NSDecimalNumber(decimal: amount)
        if zeroDecimalCountries.contains(currency.lowercased()) {
            return amountInCurrency
        } else {
            return amountInCurrency.multiplying(byPowerOf10: -2)
        }
    }
}
