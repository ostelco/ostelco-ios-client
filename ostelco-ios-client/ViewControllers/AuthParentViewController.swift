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
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupOnboarding), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func onboardingComplete() {
        onboarding = nil
        
        let tabs = UIStoryboard(name: "TabController", bundle: nil).instantiateInitialViewController()
        embedFullViewChild(tabs!)
    }
    
    @objc func setupOnboarding() {
        let navigationController = UINavigationController()
        embedFullViewChild(navigationController)
        
        let onboarding = OnboardingCoordinator(navigationController: navigationController)
        onboarding.delegate = self
        self.onboarding = onboarding
    }
}
