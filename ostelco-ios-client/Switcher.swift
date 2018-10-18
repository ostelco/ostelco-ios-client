//
//  Switcher.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit

class Switcher {
    
    static func updateRootVC(){
        
        // TODO: Verify that access token is valid
        let status = UserDefaults.standard.bool(forKey: "status")
        var rootVC : UIViewController?
        
        print(status)
        
        
        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbarvc") as! UITabBarController
        } else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        
    }
    
}
