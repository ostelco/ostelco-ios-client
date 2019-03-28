//
//  UIViewController+APIErrorAlert.swift
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
        var title = ""
        if let statusCode = error.httpStatusCode {
            message += "\(statusCode): "
        }
        
        message += error.userMessage
        
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
        let message = "Client crashed: \(error)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
