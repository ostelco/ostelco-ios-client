//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import os
import Bugsee

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        Bugsee.event("login_init")
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in
                self.handleLoginSuccess()
        },  onError: { error in
                Bugsee.logError(error: error)
                self.handleLoginError(errorMessage: "\(error)");
        })
        
    }
    
    func handleLoginSuccess() {
        Bugsee.event("login_success")
        DispatchQueue.main.async {
            AppDelegate.shared.rootViewController.switchToMainScreen()
        }
    }
    
    func handleLoginError(errorMessage: String) {
        Bugsee.event("login_failure")
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
