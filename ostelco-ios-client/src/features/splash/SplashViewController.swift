//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
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
                        
                        self.showMessage(loggedIn: true)
                        // AppDelegate.shared.rootViewController.switchToMainScreen()
                    }
                    
                    return
                }
            }
        }
        
        self.showMessage(loggedIn: false)
        // AppDelegate.shared.rootViewController.switchToLogout()
    }
    
    private func showMessage(loggedIn: Bool) {
        
        let alert: UIAlertController;
        
        if loggedIn {
            alert = UIAlertController(title: "Authentication", message: "You are logged in.", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Authentication", message: "You are not logged in.", preferredStyle: .alert)
        }
        
        perform(#selector(presentAlert), with: alert, afterDelay: 0)
    }

    @objc private func presentAlert(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alertAction in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "This is false!", style: .default, handler: { alertAction in
            self.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true)
    }
}

