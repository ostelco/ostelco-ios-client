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
    
        loginButton.layer.cornerRadius = 15.0
        loginButton.addShadow(offset: CGSize.init(width: 0, height: 0), color: UIColor.black, radius: 15.0, opacity: 0.16)
    }
    
    @IBAction func login(_ sender: Any) {
        os_log("Login button clicked")
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in
                self.handleLoginSuccess()
        },  onError: { error in
                self.handleLoginError(errorMessage: "\(error)");
        })
    }
    
    func handleLoginSuccess() {
        os_log("Login success")
        Switcher.updateRootVC()
    }
    
    func handleLoginError(errorMessage: String) {
        os_log("Login failed, show alert message to user.")
        let alert = UIAlertController(title: "Alert", message: "Failed to login: \(errorMessage)", preferredStyle: UIAlertControllerStyle.alert)
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
