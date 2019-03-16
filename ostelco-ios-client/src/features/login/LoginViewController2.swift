//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

// TODO: Remove "2" when deleting existing LoginViewController
class LoginViewController2: UIViewController {
    
    @IBAction func signInTapped(_ sender: UIButton) {
        // Trigger custom events to record button clicks
        Analytics.logEvent("button_tapped", parameters: ["newValue": sender.title(for: .normal)!])
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in
                
                // TODO: Duplicated logic from SplashViewController
                DispatchQueue.main.async {
                self.showSpinner(onView: self.view)
                APIManager.sharedInstance.customer.load()
                    .onSuccess({ data in
                        if let user: CustomerModel = data.typedContent(ifNone: nil) {
                            UserManager.sharedInstance.user = user
                            // TODO: Should check user data and redirect based on user state, for now always assume ekyc user is missing ekyc
                            DispatchQueue.main.async {
                                // TODO: For some reason, the afterDelay needs more than 0.0 when we try to navigate from the auth0 callback.
                                // In the old client, we used to set the root controller instead of performing a segue or using present
                                self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
                            }
                        } else {
                            self.showAlert(title: "Error", msg: "Failed to retrieve user.")
                        }
                    })
                    .onFailure({ error in
                        if let statusCode = error.httpStatusCode {
                            switch statusCode {
                            case 404:
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "showSignUp", sender: self)
                                }
                            default:
                                // TODO: Redirect user to generic error screen.
                                self.showAlert(title: "Error fetching customer profile", msg: error.userMessage)
                            }
                        } else {
                            // TODO: Redirect user to generic error screen.
                            self.showAlert(title: "Error fetching customer profile", msg: error.userMessage)
                        }
                    })
                    .onCompletion({ _ in
                        self.removeSpinner()
                    })
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    self.handleLoginFailure(message: "\(error)")
                }
            }
        )
    }
    
    @objc private func showCountry() {
        performSegue(withIdentifier: "showCountry", sender: self)
    }
    
    @objc private func showSignUp() {
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    private func handleLoginFailure(message: String) {
        let alert = UIAlertController(title: "Failed to login", message: "Please try again later.\nIf this problem persists, contact customer support.\n Error: \(message)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
