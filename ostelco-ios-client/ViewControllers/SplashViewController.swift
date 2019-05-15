//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

class SplashViewController: UIViewController, StoryboardLoadable {
    static let storyboard: Storyboard = .splash
    static let isInitialViewController = true
    
    @IBOutlet private weak var imageView: UIImageView!
    var spinnerView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = OstelcoColor.oyaBlue.toUIColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkIfWeHaveALoggedInUser()
    }
    
    func checkIfWeHaveALoggedInUser() {
        guard UserManager.shared.firebaseUser != nil else {
            // NOPE! We need to log in.
            UIApplication.shared.typedDelegate.rootCoordinator.showLogin()
            return
        }
        
        // YEP! Now we need to know where to send them.
        UIApplication.shared.typedDelegate.sendFCMToken()
        
        let spinnerView = self.showSpinner(onView: self.view)
        UserManager.shared.getDestinationFromContext()
            .ensure { [weak self] in
                self?.removeSpinner(spinnerView)
            }
            .done { [weak self] destination in
                guard let self = self else {
                    return
                }
                
                UIApplication.shared.typedDelegate
                    .rootCoordinator
                    .navigate(to: destination, from: self)
            }
            .catch { [weak self]error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
}
