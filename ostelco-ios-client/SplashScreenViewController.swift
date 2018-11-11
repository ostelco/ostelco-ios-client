//
//  SplashScreenViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 11/9/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        imageView.image = ThemeManager.currentTheme().logo
        sharedAuth.verifyCredentials(completion: { isLoggedIn in
            if isLoggedIn {
                AppDelegate.shared.rootViewController.switchToMainScreen()
            } else {
                AppDelegate.shared.rootViewController.switchToLogout()
            }
        })
    }
}
