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
        
        let deleteActionAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: {_ in
            self.showSpinner(onView: self.view)
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
                    self.removeSpinner()
                }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertCtrl.addAction(deleteActionAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
    
    func showLogOutActionSheet() {
        let alertCtrl = UIAlertController(title: nil, message: "Are you sure that you want to log out from your account?", preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
    
    func showNeedHelpActionSheet() {
        let alertCtrl = NeedHelpAlertController(title: "Do we want a title?", message: "We can also have a message", preferredStyle: .actionSheet)
        
        let supportAction = UIAlertAction(title: "Contact Support", style: .default, handler: {_ in
            Freshchat.sharedInstance()?.showConversations(self)
        })
        let faqAction = UIAlertAction(title: "FAQ", style: .default, handler: {_ in
            Freshchat.sharedInstance()?.showFAQs(self)
        })
        let startOverAction = UIAlertAction(title: "Start Again", style: .destructive, handler: {_ in
            self.showSpinner(onView: self.view)
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
                    self.removeSpinner()
            }
        })
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
            let buyAction = UIAlertAction(title: product.name, style: .default, handler: {_ in
                self.startApplePay(product: product, delegate: delegate)
            })
            alertCtrl.addAction(buyAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
}
