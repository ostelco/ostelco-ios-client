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

func createDeleteAccountAlertAction(title: String, vc: UIViewController) -> UIAlertAction {
    let alertAction = UIAlertAction(title: title, style: .destructive) {_ in
        let spinnerView = vc.showSpinner(onView: vc.view)
        APIManager.sharedInstance.loggedInAPI.deleteCustomer()
            .ensure { [weak vc] in
                vc?.removeSpinner(spinnerView)
            }
            .done { [weak vc] in
                UserManager.sharedInstance.logOut()
                vc?.showSplashScreen()
            }
            .catch { [weak vc] error in
                ApplicationErrors.log(error)
                vc?.showGenericError(error: error)
            }
    }
    
    return alertAction
}

extension UIViewController {
    
    @objc func showSplashScreen() {
        let viewController = SplashViewController.fromStoryboard()
        self.present(viewController, animated: true)
    }
    
    func showDeleteAccountActionSheet() {
        let alertCtrl = UIAlertController(title: nil, message: "Are you sure that you want to delete your account completely?", preferredStyle: .actionSheet)
        
        let deleteAction = createDeleteAccountAlertAction(title: "Cancel Membership", vc: self)
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
            UserManager.sharedInstance.logOut()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
    
    func showNeedHelpActionSheet() {
        let alertCtrl = NeedHelpAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let supportAction = UIAlertAction(title: "Contact Support", style: .default) {_ in
            Freshchat.sharedInstance()?.showConversations(self)
        }
        let startOverAction = createDeleteAccountAlertAction(title: "Start Again", vc: self)
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) {_ in
            UserManager.sharedInstance.logOut()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertCtrl.addAction(supportAction)
        
        alertCtrl.addAction(startOverAction)
        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
    
}
