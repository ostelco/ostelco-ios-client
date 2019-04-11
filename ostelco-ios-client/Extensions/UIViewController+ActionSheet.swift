//
//  UIViewController+ActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Stripe

// Use custom classes to get unique class names for Alerts etc
class NeedHelpAlertController: UIAlertController {
    // Or override the viewDidAppear to set the current screen name, unfortunately this will trigger two screen_view events
    /*
     override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     guard let screenName = title else {
     return
     }
     let screenClass = classForCoder.description()
     Analytics.setScreenName(screenName, screenClass: screenClass)

     }
     */
}

extension UIViewController {
    func showDeleteAccountActionSheet() {
        let alertCtrl = UIAlertController(title: nil, message: "Are you sure that you want to delete your account completely?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete Account", style: .destructive) {_ in
            let spinnerView = self.showSpinner(onView: self.view)
            APIManager.sharedInstance.customer.request(.delete)
                .onSuccess { _ in
                        sharedAuth.logout(callback: {
                            DispatchQueue.main.async {
                                let viewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController()!
                                self.present(viewController, animated: true)
                            }
                        })
                }
                .onFailure { requestError in
                    self.showAPIError(error: requestError)
                }
                .onCompletion { _ in
                    self.removeSpinner(spinnerView)
                }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertCtrl.addAction(deleteAction)
        alertCtrl.addAction(cancelAction)

        // Action sheet crashes on iPad: https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            if let popoverController = alertCtrl.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        present(alertCtrl, animated: true, completion: nil)
    }

    func showLogOutActionSheet() {
        let alertCtrl = UIAlertController(title: nil, message: "Are you sure that you want to log out from your account?", preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)

        present(alertCtrl, animated: true, completion: nil)
    }

    func showNeedHelpActionSheet() {
        let alertCtrl = NeedHelpAlertController(title: "Do we want a title?", message: "We can also have a message", preferredStyle: .actionSheet)

        let supportAction = UIAlertAction(title: "Contact Support", style: .default) {_ in
            Freshchat.sharedInstance()?.showConversations(self)
        }
        let faqAction = UIAlertAction(title: "FAQ", style: .default) {_ in
            Freshchat.sharedInstance()?.showFAQs(self)
        }
        let startOverAction = UIAlertAction(title: "Start Again", style: .destructive) {_ in
            let spinnerView = self.showSpinner(onView: self.view)
            APIManager.sharedInstance.customer.request(.delete)
                .onSuccess { _ in
                    sharedAuth.logout(callback: {
                        DispatchQueue.main.async {
                            let viewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController()!
                            self.present(viewController, animated: true)
                        }
                    })
                }
                .onFailure { requestError in
                    self.showAPIError(error: requestError)
                }
                .onCompletion { _ in
                    self.removeSpinner(spinnerView)
            }
        }
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertCtrl.addAction(supportAction)
        alertCtrl.addAction(faqAction)
        alertCtrl.addAction(startOverAction)
        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)

        present(alertCtrl, animated: true, completion: nil)
    }

    func showProductListActionSheet(products: [Product], delegate: PKPaymentAuthorizationViewControllerDelegate) {
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for product in products {
            let buyAction = UIAlertAction(title: product.name, style: .default) {_ in
                self.startApplePay(product: product, delegate: delegate)
            }
            alertCtrl.addAction(buyAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertCtrl.addAction(cancelAction)

        present(alertCtrl, animated: true, completion: nil)
    }
}
