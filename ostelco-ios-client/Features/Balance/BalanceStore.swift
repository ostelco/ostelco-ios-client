//
//  HomeStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

final class BalanceStore: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var selectedProduct: Product? = nil
    @Published var balance: String?
    
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()
        
    init() {
        loadProducts()
        fetchBalance()
    }
    
    func loadProducts() {
        APIManager.shared.primeAPI
            .loadProducts()
            .map { $0.map { Product(from: $0, countryCode: "SG") }}
            .done { self.products = $0 }
            .cauterize()
    }
    
    func fetchBalance() {
        APIManager.shared.primeAPI
            .loadBundles()
            .done { [weak self] bundles in
                debugPrint(bundles)
                self?.updateBalance(from: bundles)
            }
            .catch { error in
                ApplicationErrors.log(error)
        }
    }
    
    private func updateBalance(from bundles: [PrimeGQL.BundlesQuery.Data.Context.Bundle]) {
        guard let bundle = bundles.first else {
            return
        }
        
        let formattedBalance = self.byteCountFormatter.string(fromByteCount: bundle.balance)
        self.balance = formattedBalance
    }
}
