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
        embedSwiftUI(TabBarView(controller: self))
    }
    
    func showFreshchat() {
        FreshchatManager.shared.show(self)
    }
    
    func startOnboardingForRegionInCountry(_ country: Country, region: PrimeGQL.RegionDetailsFragment) {
        let navigationController = UINavigationController()
        let coordinator = RegionOnboardingCoordinator(country: country, region: region, localContext: RegionOnboardingContext(), navigationController: navigationController, primeAPI: primeAPI)
        coordinator.delegate = self
        currentCoordinator = coordinator
        present(navigationController, animated: true, completion: nil)
    }
    
    override func paymentSuccessful(_ product: Product?) {
        
    }
}

extension TabBarViewController: RegionOnboardingDelegate {
    func onboardingCompleteForCountry(_ country: Country) {
        dismiss(animated: true, completion: nil)
    }
    
    func onboardingCancelled() {
        dismiss(animated: true, completion: nil)
    }
}
