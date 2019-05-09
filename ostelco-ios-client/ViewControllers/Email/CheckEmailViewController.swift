//
//  CheckEmailViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CheckEmailViewController: UIViewController {
    
    @IBOutlet private var submitPasteboardOnSimulatorButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubmitPasteboardButton()
    }
    
    private func configureSubmitPasteboardButton() {
        #if targetEnvironment(simulator)
            self.submitPasteboardOnSimulatorButton.isHidden = false
        #else
            self.submitPasteboardOnSimulatorButton.isHidden = true
        #endif
    }
    
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
    
    @IBAction private func submitPasteboardTapped() {
        #if targetEnvironment(simulator)
            guard let pasteboardString = UIPasteboard.general.string else {
                self.showAlert(title: "Pasteboard was empty!", msg: "Remember to copy the link to the pasteboard first")
                return
            }
            
            guard let url = URL(string: pasteboardString) else {
                self.showAlert(title: "Can't Create URL", msg: "Couldn't create a URL from pasteboard contents:\n\n\(pasteboardString)")
                return
            }
            
            guard EmailLinkManager.isSignInLink(url) else {
                self.showAlert(title: "Not a sign in link!", msg: "The URL passed in is not a sign-in link!\n\n\(url.absoluteString)")
                return
            }
            
            let spinner = self.showSpinner(onView: self.view)
            EmailLinkManager.signInWithLink(url)
                .ensure { [weak self] in
                    self?.removeSpinner(spinner)
                }
                .then { UserManager.sharedInstance.getDestinationFromContext() }
                .done { destination in
                    UIApplication.shared.typedDelegate.rootCoordinator.navigate(to: destination, from: self)
                }
                .catch { [weak self] error in
                    ApplicationErrors.log(error)
                    self?.showGenericError(error: error)
                }
        #else
            fatalError("Submit pasteboard was somehow used when not on the simulator!")
        #endif
    }
}
