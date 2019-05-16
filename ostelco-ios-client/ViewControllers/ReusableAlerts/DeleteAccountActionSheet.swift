//
//  DeleteAccountActionSheet.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class DeleteAccountActionSheet: UIAlertController {
    
    convenience init(showingIn viewController: UIViewController) {
        self.init(title: nil,
                  message: "Are you sure that you want to delete your account completely?",
                  preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction.destructiveAction(title: "Cancel Membership") { _ in
            UserManager.shared.deleteAccount(showingIn: viewController)
        }
        self.addAction(deleteAction)
        
        self.addAction(.cancelAction())
    }
}
