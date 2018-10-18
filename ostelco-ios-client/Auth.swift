//
//  Auth.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import SimpleKeychain

class Auth {
    static let keychain = A0SimpleKeychain(service: "Auth0")
    
    static func login(accessToken: String) {
        self.keychain.setString(accessToken, forKey: "access_token")
        UserDefaults.standard.set(true, forKey: "status")
        Switcher.updateRootVC()
    }
    
    static func logout() {
        self.keychain.deleteEntry(forKey: "access_token")
        UserDefaults.standard.set(false, forKey: "status")
        Switcher.updateRootVC()
    }

}
