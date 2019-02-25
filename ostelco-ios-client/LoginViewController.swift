//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import os

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  func setAuth() {
    sharedAuth.credentialsManager.credentials { error, credentials in
      if error == nil, let credentials = credentials {
        if let accessToken = credentials.accessToken {
          DispatchQueue.main.async {
            if (ostelcoAPI.authToken != accessToken && ostelcoAPI.authToken != nil) {
              ostelcoAPI.wipeResources()
            }

            if (ostelcoAPI.authToken != accessToken) {
              ostelcoAPI.authToken = "Bearer \(accessToken)"
            }

            if let refreshToken = credentials.refreshToken {
              ostelcoAPI.refreshToken = refreshToken
            }
            self.handleLoginSuccess()
          }
        }
      }
    }
  }

  @IBAction func login(_ sender: Any) {
        os_log("Login button clicked")
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in
                self.setAuth()
                //self.handleLoginSuccess()
        },  onError: { error in
                self.handleLoginError(errorMessage: "\(error)");
        })
        
    }
    
    func handleLoginSuccess() {
        os_log("Login success")
        DispatchQueue.main.async {
            AppDelegate.shared.rootViewController.switchToMainScreen()
        }
    }
    
    func handleLoginError(errorMessage: String) {
        os_log("Login failed, show alert message to user.")
        let alert = UIAlertController(title: "Alert", message: "Failed to login: \(errorMessage)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
}
