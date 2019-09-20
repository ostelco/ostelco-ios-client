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
            FreshchatManager.shared.show(viewController)
        }
        self.addAction(supportAction)
        
        #if DEV
        if UserManager.shared.customer != nil {
            let startOverAction = UIAlertAction.destructiveAction(title: "Start Again") { _ in
                UserManager.shared.deleteAccount(showingIn: viewController)
            }
            self.addAction(startOverAction)
        }
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
