//
//  UIViewController+Alerts.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Shows a generic error message based on a Swift error, particularly if it's localizable.
    ///
    /// - Parameters:
    ///   - error: The error to show.
    ///   - completion: [optional] The completion block to execute as the alert is dismissed. Defaults to nil.
    func showGenericError(error: Error, completion: ((UIAlertAction) -> Void)? = nil) {
        let message: String
            
        switch error {
        case APIHelper.Error.jsonError(let jsonError):
            message = jsonError.message
        case APIHelper.Error.serverError(let serverError):
            message = serverError.errors.joined(separator: "\n\n")
        default:
            if let localized = error as? LocalizedError {
                message = localized.localizedDescription
            } else {
                message = "An error has occurred:\n\n\(error)"
            }
        }
        
        self.showAlert(title: "Error", msg: message, completion: completion)
    }
    
    /// Shows an alert with an OK button.
    ///
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - msg: The message of the alert.
    ///   - completion: [optional] The completion block to execute as the alert is dismissed. Defaults to nil.
    func showAlert(title: String, msg: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(.okAction(completion: completion))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    /// Method to compensate for action sheet crashes on the iPad
    ///
    /// - Parameter alertController: The alert controller to present as an action sheet.
    func presentActionSheet(_ alertController: UIAlertController) {
        // Action sheet crashes on iPad: https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        } else {
            self.present(alertController, animated: true)
        }
    }
    
    func showNeedHelpActionSheet() {
        let needHelp = NeedHelpAlertController(showingIn: self)
        self.presentActionSheet(needHelp)
    }
}
