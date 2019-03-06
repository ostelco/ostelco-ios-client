//
//  UIViewController+NeedHelpActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    func showNeedHelpActionSheet() {
        let alertCtrl = UIAlertController(title: "Do we want a title?", message: "We can also have a message", preferredStyle: .actionSheet)
        
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
