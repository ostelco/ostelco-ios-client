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
                        
                        // TODO: Handle redirect logic. Remember that this redirect logic should also be handled after you successfully login from the login screen.
                        // AppDelegate.shared.rootViewController.switchToMainScreen() // Old redirect logic
                    }
                    
                    return
                }
            }
        }
        
        self.showMessage(loggedIn: false)
        // TODO: Redirect to login screen. Remember to clean up any local state from authentication
        // AppDelegate.shared.rootViewController.switchToLogout() // Old redirect logic
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
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { alertAction in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Take me to login screen", style: .default, handler: { alertAction in
            self.performSegue(withIdentifier: "unwindFromSplashViewController", sender: self)
        }))

        self.present(alert, animated: true)
    }
}

