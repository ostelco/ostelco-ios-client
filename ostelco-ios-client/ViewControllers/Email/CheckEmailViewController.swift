//
//  CheckEmailViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CheckEmailViewController: UIViewController {
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func resendTapped() {
        guard let email = UserDefaultsWrapper.pendingEmail else {
            assertionFailure("No pending email?!")
            return
        }
        
        let spinnerView = self.showSpinner(onView: self.view)
        EmailLinkManager.linkEmail(email)
            .ensure { [weak self] in
                self?.removeSpinner(spinnerView)
            }
            .done { [weak self] in
                self?.showAlert(title: "Resent!", msg: "We've resent your email to \(email). If you're still having issues, please contact support.")
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
}
