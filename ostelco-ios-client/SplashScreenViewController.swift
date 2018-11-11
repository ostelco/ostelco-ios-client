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
        verifyCredentials()
    }
    
    func verifyCredentials() {
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
                        
                        AppDelegate.shared.rootViewController.switchToMainScreen()
                    }
                    
                    return
                }
            }
        }
        
        AppDelegate.shared.rootViewController.switchToLogout()
    }
}
