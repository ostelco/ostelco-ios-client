//
//  UIViewController+Alerts.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Siesta

extension UIViewController {
    
    func showAPIError(error: RequestError, completion: ((_:UIAlertAction) -> Void)? = nil) {
        var message = ""
        if let statusCode = error.httpStatusCode {
            message += "\(statusCode): "
        }
        message += error.userMessage
        
        var title = ""
        if error.cause != nil {
            title += "Internal client error"
        }
        if error.entity != nil {
            title += "Domain specific error"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: completion))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showGenericError(error: Error) {
        let title = "Error"
        let message = "An error has occurred:\n\n\(error)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
