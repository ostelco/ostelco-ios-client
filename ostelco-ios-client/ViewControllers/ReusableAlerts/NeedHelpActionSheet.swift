//
//  NeedHelpActionSheet.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class NeedHelpAlertController: UIAlertController {
    
    convenience init(showingIn viewController: UIViewController) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let supportAction = UIAlertAction(title: "Contact Support", style: .default) {_ in
            Freshchat.sharedInstance()?.showConversations(viewController)
        }
        self.addAction(supportAction)
        
        let startOverAction = UIAlertAction.destructiveAction(title: "Start Again") { _ in
           UserManager.shared.deleteAccount(showingIn: viewController)
        }
        self.addAction(startOverAction)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) {_ in
            UserManager.shared.logOut()
            let loginVC = LoginViewController.fromStoryboard()
            viewController.present(loginVC, animated: true)
        }
        self.addAction(logOutAction)
        
        self.addAction(.cancelAction())
    }
}