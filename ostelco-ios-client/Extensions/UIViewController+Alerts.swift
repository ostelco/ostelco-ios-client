//
//  UIViewController+Alerts.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

extension UIViewController {
    
    func showGenericError(error: Error) {
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
        
        self.showAlert(title: "Error", msg: message)
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(.okAction())
        self.present(alert, animated: true, completion: nil)
    }
}
