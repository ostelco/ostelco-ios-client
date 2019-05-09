//
//  FirebaseAuthUser+PromiseKit.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import FirebaseAuth
import PromiseKit

extension FirebaseAuth.User {
    
    enum Error: Swift.Error, LocalizedError {
        case noErrorAndNoToken
        
        var localizedDescription: String {
            // TODO: Actually localize
            switch self {
            case .noErrorAndNoToken:
                return "Atttempted to get ID token from Firebase, but got neither an error nor a token"
            }
        }
    }

    func promiseGetIDToken(forceRefresh: Bool = false) -> Promise<String> {
        return Promise { seal in
            self.getIDTokenForcingRefresh(forceRefresh) { token, error in
                if let firebaseError = error {
                    seal.reject(firebaseError)
                    return
                }
                
                guard let token = token else {
                    seal.reject(Error.noErrorAndNoToken)
                    return
                }
                
                seal.fulfill(token)
            }
        }
    }
}
