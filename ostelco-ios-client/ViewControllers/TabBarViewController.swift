//
//  TabBarViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ostelco_core
import Stripe

class TabBarViewController: ApplePayViewController {
    
    var currentCoordinator: RegionOnboardingCoordinator?
    let primeAPI = APIManager.shared.primeAPI
    
    var tabBar: TabBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar = TabBarView(controller: self)
        embedSwiftUI(tabBar!)
    }
    
    func showFreshchat() {
        FreshchatManager.shared.show(self)
    }
    
    func startOnboardingForRegion(_ region: PrimeGQL.RegionDetailsFragment, targetCountry: Country) {
        currentCoordinator = nil
        
        let navigationController = UINavigationController()
        let coordinator = RegionOnboardingCoordinator(
            region: region,
            targetCountry: targetCountry,
            localContext: RegionOnboardingContext(),
            navigationController: navigationController,
            primeAPI: primeAPI
        )
        coordinator.delegate = self
        currentCoordinator = coordinator
        present(navigationController, animated: true, completion: nil)
    }
    
    override func paymentSuccessful(_ product: Product?) {
        if let product = product {
            OstelcoAnalytics.logEvent(.ecommercePurchase(currency: product.currency, value: product.stripeAmount, tax: product.stripeTax))
        }
        tabBar?.resetTabs()
    }
}

extension TabBarViewController: RegionOnboardingDelegate {
    func onboardingCompleteForRegion(_ regionID: String) {
        currentCoordinator = nil
        dismiss(animated: true) {
            self.tabBar?.resetTabs()
        }
    }
    
    func onboardingCancelled() {
        currentCoordinator = nil
        dismiss(animated: true, completion: nil)
    }
}
