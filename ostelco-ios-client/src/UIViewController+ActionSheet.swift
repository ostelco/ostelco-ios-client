//
//  UIViewController+ActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    func showDeleteAccountActionSheet() {
        let alertCtrl = UIAlertController(title: nil, message: "Are you sure that you want to delete your account completely?", preferredStyle: .actionSheet)
        
        let deleteActionAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: {_ in
            sharedAuth.logout()
            let viewController = UIStoryboard(name: "Splash", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true)
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
}
