//
//  FirebaseSignInManager.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 19/08/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import FirebaseAuth
import PromiseKit
import ostelco_core

struct FirebaseSignInManager {
    
    enum Error: Swift.Error, LocalizedError {
        case noErrorAndNoUser

        var localizedDescription: String {
            switch self {
            case .noErrorAndNoUser:
                return NSLocalizedString("Signed into Firebase and received neither a user nor an error!", comment: "Error case during firebase auth when we could not get a user.")
            }
        }
    }
    
    static func signInWithCustomToken(customToken: String) -> Promise<Void> {
        return Promise { seal in
            Auth.auth().signIn(withCustomToken: customToken) { authDataResult, error in
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
