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
            
            let options = FAQOptions.init()
            
            /*
            ref: https://support.freshchat.com/support/solutions/articles/229394-freshchat-ios-sdk-swift-integration
            options.showFaqCategoriesAsGrid = false; // Set false to show faq in list view
            options.showContactUsOnAppBar = true; // Set false to hide contact us from app bar
            options.showContactUsOnFaqScreens = true; // Set false to hide contact us bottom banner view
            */
            Freshchat.sharedInstance()?.showFAQs(viewController, with: options)
        }
        self.addAction(supportAction)
        
        let startOverAction = UIAlertAction.destructiveAction(title: "Start Again") { _ in
           UserManager.shared.deleteAccount(showingIn: viewController)
        }
        self.addAction(startOverAction)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) {_ in
            UserManager.shared.logOut()
            UIApplication.shared.typedDelegate.rootCoordinator.goBackToLogin()
        }
        
        self.addAction(logOutAction)
        
        self.addAction(.cancelAction())
    }
}
