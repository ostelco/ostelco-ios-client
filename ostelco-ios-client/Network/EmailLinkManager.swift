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
import ostelco_core

struct EmailLinkManager {
    
    enum Error: Swift.Error, LocalizedError {
        case couldntCreateFirebaseURL
        case noErrorAndNoUser
        case noPendingEmailStored
        
        var localizedDescription: String {
            switch self {
            case .couldntCreateFirebaseURL:
                return NSLocalizedString("Couldn't create a URL from the firebase projectID!", comment: "Error case during firebase auth when it fails to create a signin url.")
            case .noErrorAndNoUser:
                return NSLocalizedString("Signed into Firebase and received neither a user nor an error!", comment: "Error case during firebase auth when we could not get a user.")
            case .noPendingEmailStored:
                return NSLocalizedString("The pending email was not stored locally, so we could not validate the sign in.", comment: "Error case during firebase auth when we could not validate sign-in.")
            }
        }
    }
    
    static func linkEmail(_ emailAddress: String) -> Promise<Void> {
        let base = Environment().configuration(.FirebaseProjectID)
        let urlString = "https://\(base).firebaseapp.com"
        guard let url = URL(string: urlString) else {
            return Promise(error: Error.couldntCreateFirebaseURL)
        }
        
        let settings = ActionCodeSettings()
        settings.url = url
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
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
        
    static func isSignInLink(_ link: URL) -> Bool {
        return Auth.auth().isSignIn(withEmailLink: link.absoluteString)
    }
    
    static func signInWithLink(_ link: URL, email: String) -> Promise<Void> {
        return Promise { seal in
            // We are going to login with this email, clear it now, so if it fails you start over
            UserDefaultsWrapper.pendingEmail = nil
            Auth.auth().signIn(withEmail: email, link: link.absoluteString) { authDataResult, error in
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
