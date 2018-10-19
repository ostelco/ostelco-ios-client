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
    
    static func updateRootVC(){
        os_log("update root VC...")
        
        var rootVC : UIViewController?
        
        os_log("Validate auth credentials")
        if sharedAuth.credentialsManager.hasValid() {
            os_log("auth credentials valid, redirect to tab bar vc.")
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
        } else {
            os_log("Could not find valid auth credentials, clear credentials and show login vc")
            sharedAuth.clear()
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        }
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
    
}
