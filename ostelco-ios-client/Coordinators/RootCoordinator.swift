//
//  RootCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

enum PostLoginDestination {
    case ekycLastScreen
    case ekycOhNo
    case esimSetup
    case home
    case signupStart
    case validateCountry
}


class RootCoordinator {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    var rootViewController: UIViewController? {
        return self.window.rootViewController
    }
    
    func replaceRootViewController(with newRoot: UIViewController) {
        self.window.rootViewController = newRoot
    }
    
    func showLogin() {
        let loginViewController = LoginViewController.fromStoryboard()
        self.rootViewController?.present(loginViewController, animated: true)
    }
    
    func showEmailEntry() {
        guard let emailNav = Storyboard.email.asUIStoryboard.instantiateInitialViewController() else {
            assertionFailure("Could not instantiate email nav!")
            return
        }
        
        self.rootViewController?.present(emailNav, animated: true)
    }
    
    func navigate(to destination: PostLoginDestination, from viewController: UIViewController) {
        switch destination {
        case .ekycLastScreen:
            let pendingVerification = PendingVerificationViewController.fromStoryboard()
            viewController.present(pendingVerification, animated: true)
        case .ekycOhNo:
            self.showOhNo(from: viewController)
        case .esimSetup:
            let esim = ESIMOnBoardingViewController.fromStoryboard()
            viewController.present(esim, animated: true)
        case .home:
            let tabs = TabBarController.fromStoryboard()
            viewController.present(tabs, animated: true)
        case .signupStart:
            let legalVC = TheLegalStuffViewController.fromStoryboard()
            viewController.present(legalVC, animated: true)
        case .validateCountry:
            let countryVC = VerifyCountryOnBoardingViewController.fromStoryboard()
            viewController.present(countryVC, animated: true)
        }
    }
    
    private func showOhNo(from viewController: UIViewController) {
        let ohNo = OhNoViewController.fromStoryboard(type: .ekycRejected)
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak viewController] in
                guard let vc = viewController else {
                    return
                }
                
                let selectVerificationMethodVC = SelectIdentityVerificationMethodViewController.fromStoryboard()
                vc.present(selectVerificationMethodVC, animated: true)
            })
        }
        viewController.present(ohNo, animated: true)
    }
}
