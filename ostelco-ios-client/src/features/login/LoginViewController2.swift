//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// TODO: Remove "2" when deleting existing LoginViewController
class LoginViewController2: UIViewController {
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in
                self.handleLoginSuccess()
            },
            onError: { error in
                self.handleLoginFailure(message: "\(error)")
            }
        )
    }
    
    private func handleLoginSuccess() {
        performSegue(withIdentifier: "unwindFromLoginViewController", sender: self)
    }
    
    private func handleLoginFailure(message: String) {
        let alert = UIAlertController(title: "Failed to login", message: "Please try again later.\nIf this problem persists, contact customer support.\n Error: \(message)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
