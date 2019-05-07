//
//  EmailLinkManager.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import FirebaseAuth
import PromiseKit

struct EmailLinkManager {
    
    enum Error: Swift.Error, LocalizedError {
        case noErrorAndNoUser
        case noPendingEmailStored
        
        var localizedDescription: String {
            // TODO: Actually localize
            switch self {
            case .noErrorAndNoUser:
                return "Signed into Firebase and received neither a user nor an error!"
            case .noPendingEmailStored:
                return "The pending email was not stored locally, so we could not validate the sign in."
            }
        }
    }
    
    static func linkEmail(_ emailAddress: String) -> Promise<Void> {
        let settings = ActionCodeSettings()
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        UserDefaultsWrapper.pendingEmail = emailAddress
        
        return Promise { seal in
            Auth.auth().sendSignInLink(
                toEmail: emailAddress,
                actionCodeSettings: settings) { error in
                    if let firebaseError = error {
                        seal.reject(firebaseError)
                    } else {
                        seal.fulfill(())
                    }
                }
        }
    }
        
    static func isSignInLink(_ link: String) -> Bool {
        return Auth.auth().isSignIn(withEmailLink: link)
    }
    
    static func signInWithLink(_ link: String) -> Promise<Void> {
        guard let email = UserDefaultsWrapper.pendingEmail else {
            return Promise(error: Error.noPendingEmailStored)
        }
        
        return Promise { seal in
            Auth.auth().signIn(withEmail: email, link: link) { authDataResult, error in
                if let firebaseError = error {
                    seal.reject(firebaseError)
                    return
                }
                
                guard authDataResult?.user != nil else {
                    seal.reject(Error.noErrorAndNoUser)
                    return
                }
                
                seal.fulfill(())
            }
        }
    }
}
