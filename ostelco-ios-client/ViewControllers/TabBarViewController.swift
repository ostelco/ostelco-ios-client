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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embedSwiftUI(TabBarView(controller: self))
    }
    
    func showFreshchat() {
        FreshchatManager.shared.show(self)
    }
    
    func startOnboardingForRegion(_ region: PrimeGQL.RegionDetailsFragment) {
        let navigationController = UINavigationController()
        let coordinator = RegionOnboardingCoordinator(region: region, localContext: RegionOnboardingContext(), navigationController: navigationController, primeAPI: primeAPI)
        coordinator.delegate = self
        currentCoordinator = coordinator
        present(navigationController, animated: true, completion: nil)
    }
    
    override func paymentSuccessful(_ product: Product?) {
        if let product = product {
            OstelcoAnalytics.logEvent(.ecommercePurchase(currency: product.currency, value: product.amount, tax: product.tax))
        }
        if let parent = self.parent as? AuthParentViewController {
            parent.onboardingComplete(force: true)
        }
    }
}

extension TabBarViewController: RegionOnboardingDelegate {
    func onboardingCompleteForRegion(_ regionID: String) {
        dismiss(animated: true, completion: nil)
        if let parent = self.parent as? AuthParentViewController {
            parent.onboardingComplete(force: true)
        }
    }
    
    func onboardingCancelled() {
        dismiss(animated: true, completion: nil)
    }
}
