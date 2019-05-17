//
//  LogOutActionSheet.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class LogOutActionSheet: UIAlertController {
    
    convenience init(showingIn viewController: UIViewController) {
        self.init(title: nil,
                  message: "Are you sure that you want to log out from your account?",
                  preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction.destructiveAction(title: "Log Out") {_ in
            UserManager.shared.logOut()
            let loginVC = LoginViewController.fromStoryboard()
            viewController.present(loginVC, animated: true)
        }
        self.addAction(logOutAction)
        
        self.addAction(.cancelAction())
    }
}
