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
    
    var topViewController: UIViewController? {
        return self.window.rootViewController?.topPresentedViewController()
    }
    
    func replaceRootViewController(with newRoot: UIViewController) {
        self.window.rootViewController = newRoot
    }
    
    func showLogin() {
        let loginViewController = LoginViewController.fromStoryboard()
        self.topViewController?.present(loginViewController, animated: true)
    }
    
    func showEmailEntry() {
        guard let emailNav = Storyboard.email.asUIStoryboard.instantiateInitialViewController() else {
            assertionFailure("Could not instantiate email nav!")
            return
        }
        
        self.topViewController?.present(emailNav, animated: true)
    }
    
    func navigate(to destination: PostLoginDestination, from viewController: UIViewController?) {
        let presentingViewController: UIViewController
        if let passedInVC = viewController {
            presentingViewController = passedInVC
        } else if let topVC = self.topViewController {
            presentingViewController = topVC
        } else {
            assertionFailure("No view controller?!")
            return
        }
        
        switch destination {
        case .ekycLastScreen:
            let pendingVerification = PendingVerificationViewController.fromStoryboard()
            presentingViewController.present(pendingVerification, animated: true)
        case .ekycOhNo:
            self.showOhNo(from: presentingViewController)
        case .esimSetup:
            let esim = ESIMOnBoardingViewController.fromStoryboard()
            presentingViewController.present(esim, animated: true)
        case .home:
            let tabs = TabBarController.fromStoryboard()
            presentingViewController.present(tabs, animated: true)
        case .signupStart:
            let legalVC = TheLegalStuffViewController.fromStoryboard()
            presentingViewController.present(legalVC, animated: true)
        case .validateCountry:
            let countryVC = VerifyCountryOnBoardingViewController.fromStoryboard()
            presentingViewController.present(countryVC, animated: true)
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
