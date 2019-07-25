//
//  PurchaseRecord.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 24/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import ostelco_core

class PurchaseRecord {
    let name: String
    let amount: String
    let date: String

    private static var  dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(name: String, amount: String, date: String) {
        self.name = name
        self.amount = amount
        self.date = date
    }

    init(from: PrimeGQL.PurchasesQuery.Data.Context.Purchase) {
        let strDate = PurchaseRecord.dateFormatter.string(
            from: Date(timeIntervalSince1970: (Double(from.timestamp) / 1000.0))
        )
        name = from.product.fragments.productFragment.presentation.productLabel
        amount = from.product.fragments.productFragment.presentation.priceLabel
        date = strDate
    }
}
