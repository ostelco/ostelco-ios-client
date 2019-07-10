//
//  AuthParentViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthParentViewController: UIViewController, OnboardingCoordinatorDelegate {
    var onboarding: OnboardingCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOnboarding()
        
        Auth.auth().addStateDidChangeListener { (_, user) in
            if user == nil {
                self.setupOnboarding()
            }
        }
    }

    func onboardingComplete() {
        onboarding = nil
        
        let tabs = TabBarController.fromStoryboard()
        embedFullViewChild(tabs)
    }
    
    func setupOnboarding() {
        let navigationController = UINavigationController()
        embedFullViewChild(navigationController)
        
        let onboarding = OnboardingCoordinator(navigationController: navigationController)
        onboarding.delegate = self
        self.onboarding = onboarding
    }
}
