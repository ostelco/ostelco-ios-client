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

class UserManager {
    static let sharedInstance = UserManager()
    
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
    
    func clear() {
        authToken = nil
    }
    
    private var firebaseUser: FirebaseAuth.User? {
        return FirebaseAuth.Auth.auth().currentUser
    }
    
    var currentUserEmail: String? {
        return self.firebaseUser?.email
    }
}
