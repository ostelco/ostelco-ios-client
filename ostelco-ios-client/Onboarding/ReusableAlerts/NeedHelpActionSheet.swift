//
//  NeedHelpActionSheet.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Crashlytics

class NeedHelpAlertController: UIAlertController {
    
    convenience init(showingIn viewController: UIViewController) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let supportAction = UIAlertAction(title: "Contact Support", style: .default) {_ in
            Freshchat.sharedInstance()?.showFAQs(viewController)
        }
        self.addAction(supportAction)
        
        #if DEV
        if UserManager.shared.customer != nil {
            let startOverAction = UIAlertAction.destructiveAction(title: "Start Again") { _ in
                UserManager.shared.deleteAccount(showingIn: viewController)
            }
            self.addAction(startOverAction)
        }
        
        let crashlyticsAction = UIAlertAction(title: "Trigger Crashlytics Crash", style: .default) { _ in
            ApplicationErrors.log(ApplicationErrors.General.noMyInfoConfigFound)
            Crashlytics.sharedInstance().crash()
        }
        
        self.addAction(crashlyticsAction)
        #endif
        
        if UserManager.shared.hasCurrentUser {
            let logOutAction = UIAlertAction(title: "Log Out", style: .default) {_ in
                UserManager.shared.logOut()
            }
            self.addAction(logOutAction)
        }
        
        self.addAction(.cancelAction())
    }
}
