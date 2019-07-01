//
//  AuthParentViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthParentViewController: UIViewController {
    
    private(set) lazy var rootCoordinator: RootCoordinator = {
        return RootCoordinator(root: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForAuthState()
    }
    
    private func listenForAuthState() {
        Auth.auth().addStateDidChangeListener { (_, user) in
            if user == nil {
                // NOPE! We need to log in.
                let vc = LoginViewController.fromStoryboard()
                vc.rootCoordinator = self.rootCoordinator
                self.embedFullViewChild(vc)
            } else {
                self.embedFullViewChild(SplashViewController.fromStoryboard())
                self.rootCoordinator
                    .determineAndNavigateToDestination()
            }
        }
    }

}
