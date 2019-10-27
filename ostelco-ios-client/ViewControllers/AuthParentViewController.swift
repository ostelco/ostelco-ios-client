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
    var onboardingRoot: UIViewController?
    var mainRoot: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOnboarding()
        
        Auth.auth().addStateDidChangeListener { (_, user) in
            if user == nil {
                self.setupOnboarding()
            } else {
                OstelcoAnalytics.logEvent(.signIn)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupOnboarding), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func onboardingComplete() {
        killOldOnboarding()
        
        if mainRoot == nil {
            let tabs = UIStoryboard(name: "TabController", bundle: nil).instantiateInitialViewController()
            mainRoot = tabs
            embedFullViewChild(tabs!)
        }
    }
    
    private func killOldOnboarding() {
        onboarding = nil
        
        onboardingRoot?.willMove(toParent: nil)
        onboardingRoot?.view.removeFromSuperview()
        onboardingRoot?.removeFromParent()
        onboardingRoot = nil
    }
    
    @objc func setupOnboarding() {
        killOldOnboarding()
        
        let navigationController = UINavigationController()
        onboardingRoot = navigationController
        embedFullViewChild(navigationController, removePrevious: false)
        
        let onboarding = OnboardingCoordinator(navigationController: navigationController)
        onboarding.delegate = self
        self.onboarding = onboarding
    }
}
