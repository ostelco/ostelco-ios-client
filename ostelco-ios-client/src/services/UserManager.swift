//
//  DataManager.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

class UserManager {
    static let sharedInstance = UserManager()

    var authToken: String?
    var user: CustomerModel! {
        didSet {
            if user == nil {
                Freshchat.sharedInstance().resetUser(completion: { () in
                    //Completion code
                })
            } else {
                Freshchat.sharedInstance().identifyUser(withExternalID: user.id, restoreID: nil)
                let fcUser = FreshchatUser.sharedInstance();
                fcUser?.firstName = user.name
                fcUser?.email = user.email
                Freshchat.sharedInstance().setUser(fcUser)
            }
            
        }
    }

    func clear() {
        authToken = nil
    }
}
