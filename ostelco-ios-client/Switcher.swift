//
//  Switcher.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
import os

class Switcher {
    
    static func handleInvalidCredentials() {
        os_log("Could not find valid auth credentials, clear credentials and show login vc")
        sharedAuth.clear()
        ostelcoAPI.authToken = nil
        let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        setRootView(rootVC: rootVC)
    }
    
    static func setRootView(rootVC: UIViewController) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
    
    static func updateRootVC(){
        os_log("update root VC...")
        os_log("Validate auth credentials")
        sharedAuth.credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                handleInvalidCredentials()
                return
            }
            guard let accessToken = credentials.accessToken else {
                handleInvalidCredentials()
                return
            }
            
            os_log("Use access token to set auth header in api client: %{private}@", accessToken)
            ostelcoAPI.authToken = "Bearer \(accessToken)"
            
            os_log("auth credentials valid, redirect to tab bar vc.")
            let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
            setRootView(rootVC: rootVC)
        }
    }
    
}
