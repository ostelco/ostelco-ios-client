//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Auth0
import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func login(_ sender: Any) {
        
        Auth0
            .webAuth()
            .responseType([ResponseType.token])
            .scope("openid profile email offline_access")
            .audience("http://google_api")
            .connection("google-oauth2")
            .start {
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                    let alert = UIAlertController(title: "Alert", message: "Failed to login. Try again later.", preferredStyle: UIAlertControllerStyle.alert)
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
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the login page
                    print("Credentials: \(credentials)")
                    guard let accessToken = credentials.accessToken else { fatalError("Could not get access token from auth0 credentials") }
                    Auth.login(accessToken: accessToken)
                }
        }
    }
}
