//
//  HomeStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

final class BalanceStore: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var selectedProduct: Product?
    @Published var balance: String?
    @Published var hasAtLeastOneApprovedCountry: Bool = false
    
    let controller: TabBarViewController
    
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()
        
    init(controller: TabBarViewController) {
        self.controller = controller
        loadProducts()
        fetchBalance()
        checkRegions()
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
                self?.updateBalance(from: bundles)
            }
            .catch { error in
                ApplicationErrors.log(error)
        }
    }
    
    func checkRegions() {
        APIManager.shared.primeAPI.loadRegions()
            .filterValues({ (region) -> Bool in
                return region.status == .approved
            })
            .done { result in
                self.hasAtLeastOneApprovedCountry = result.isNotEmpty
            }.catch { error in
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
