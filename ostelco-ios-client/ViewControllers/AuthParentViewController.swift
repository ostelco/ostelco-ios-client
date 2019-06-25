//
//  AuthParentViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class AuthParentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserManager.shared.hasCurrentUser {
            embedFullViewChild(SplashViewController.fromStoryboard())
        } else {
            // NOPE! We need to log in.
            embedFullViewChild(LoginViewController.fromStoryboard())
        }
    }
}
