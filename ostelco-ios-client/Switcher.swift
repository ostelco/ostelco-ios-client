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
    
    // TODO: Refactor function to remove code duplication. Investigte if option 2 can replace option 1
    static func updateRootVC(){
        os_log("update root VC...")
        
        var rootVC : UIViewController?
        
        os_log("Validate auth credentials")
        
        // Option 1
        if sharedAuth.credentialsManager.hasValid() {
            os_log("auth credentials valid, redirect to tab bar vc.")
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
        } else {
            os_log("Could not find valid auth credentials, clear credentials and show login vc")
            sharedAuth.clear()
            ostelcoAPI.authToken = nil
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        }
        
        // Option 2
        sharedAuth.credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                os_log("Could not find valid auth credentials, clear credentials and show login vc")
                sharedAuth.clear()
                ostelcoAPI.authToken = nil
                rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = rootVC
                return
            }
            guard let accessToken = credentials.accessToken else {
                os_log("Could not find valid auth credentials, clear credentials and show login vc")
                sharedAuth.clear()
                ostelcoAPI.authToken = nil
                rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = rootVC
                return
            }
            
            os_log("Use access token to set auth header in api client: %{private}@", accessToken)
            ostelcoAPI.authToken = "Bearer \(accessToken)"
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootVC
        }
    }
    
}
