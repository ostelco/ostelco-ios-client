//
//  DataManager.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import FirebaseAuth
import FirebaseUI
import ostelco_core

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    private(set) lazy var authUI: FUIAuth = {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            fatalError("Could not instantiate firebase UI!")
        }
        
        authUI.delegate = self
        authUI.providers = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            FUITwitterAuth(),
        ]
        
        return authUI
    }()
    
    var user: CustomerModel? {
        didSet {
            guard let user = self.user else {
                Freshchat.sharedInstance().resetUser(completion: { () in
                    //Completion code
                })
                Crashlytics.sharedInstance().setUserIdentifier(nil)
                return
            }
            
            Freshchat.sharedInstance().identifyUser(withExternalID: user.id, restoreID: nil)
            let fcUser = FreshchatUser.sharedInstance()
            fcUser?.firstName = user.name
            fcUser?.email = user.email
            Freshchat.sharedInstance().setUser(fcUser)
            
            Crashlytics.sharedInstance().setUserIdentifier(user.id)
            Crashlytics.sharedInstance().setUserName(user.name)
            Crashlytics.sharedInstance().setUserEmail(user.email)
        }
    }
    
    func handleApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        guard let sourceApplication = options[.sourceApplication] as? String else {
            assertionFailure("No source application?!")
            // Something else should handle this
            return false
        }
        
        return UserManager.sharedInstance.authUI.handleOpen(url, sourceApplication: sourceApplication)
    }
    
    private var firebaseUser: FirebaseAuth.User? {
        return FirebaseAuth.Auth.auth().currentUser
    }
    
    var currentUserEmail: String? {
        return self.firebaseUser?.email
    }
    
    func getCurrentToken() -> Promise<String> {
        return Promise { seal in
//            FirebaseAuth.Auth.auth().currentUser.gettokn
        }
    }
    
    func showLogin(from viewController: UIViewController) {
        viewController.present(self.authUI.authViewController(), animated: true)
    }
        
    func logOut() {
        do {
            try self.authUI.signOut()
        } catch let error {
            ApplicationErrors.log(error)
        }
    }
}

extension UserManager: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        #warning("HANDLE USER OR ERROR HERE")
    }
}
