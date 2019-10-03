//
//  UsernameAndPasswordLinkManager.swift
//  ostelco-ios-client
//
//  Created by mac on 10/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import FirebaseAuth
import PromiseKit
import ostelco_core

struct UsernameAndPasswordLinkManager {
    
    enum Error: Swift.Error, LocalizedError {
        case noUsernameOrPassword
        case noErrorAndNoUser
        
        var localizedDescription: String {
            switch self {
            case .noUsernameOrPassword:
                return "Could not find username or password in URL"
            case .noErrorAndNoUser:
                return "Signed into Firebase and received neither a user nor an error!"
            }
        }
    }
        
    static func isUsernameAndPasswordLink(_ link: URL) -> Bool {
        if LinkHelper.getLastPathFromLink(link) == "login-with-username-and-password", LinkHelper.linkContainsParams(link, paramKeys: ["username", "password"]) {
            return true
        }
        
        return false
    }
    
    static func signInWithUsernameAndPassword(_ link: URL) -> Promise<Void> {
        return Promise { seal in
            
            let params = LinkHelper.parseLink(link)
            
            guard let username = params["username"], let password = params["password"] else {
                seal.reject(Error.noUsernameOrPassword)
                return
            }
            
            Auth.auth().signIn(withEmail: username, password: password) { authDataResult, error in
                if let firebaseError = error {
                    seal.reject(firebaseError)
                    return
                }
                
                guard authDataResult?.user != nil else {
                    seal.reject(Error.noErrorAndNoUser)
                    return
                }
            
                UserDefaultsWrapper.contactEmail = username
                seal.fulfill(())
            }
        }
    }
}
