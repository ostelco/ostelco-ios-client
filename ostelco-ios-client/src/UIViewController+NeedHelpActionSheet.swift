//
//  UIViewController+NeedHelpActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

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
    func showNeedHelpActionSheet() {
        let alertCtrl = NeedHelpAlertController(title: "Do we want a title?", message: "We can also have a message", preferredStyle: .actionSheet)
        
        let supportAction = UIAlertAction(title: "Contact Support", style: .default, handler: {_ in
            let alert = UIAlertController(title: "Halp!!!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        })
        let startOverAction = UIAlertAction(title: "Start Again", style: .destructive, handler: {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        })
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertCtrl.addAction(supportAction)
        alertCtrl.addAction(startOverAction)
        alertCtrl.addAction(logOutAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
}
