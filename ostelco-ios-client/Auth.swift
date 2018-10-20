//
//  Auth.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import SimpleKeychain
import Auth0
import UIKit
import RxSwift
import os

let sharedAuth = Auth()

class Auth {
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    func clear() {
        os_log("Clear credentials in auth0 credentials manager.")
        self.credentialsManager.clear()
    }
    
    func logout() {
        os_log("Logout user")
        self.clear()
        Switcher.updateRootVC()
    }
    
    func loginWithAuth0() -> Observable<Void> {
        os_log("Start login with auth0...")
        return Observable.create { observer in
            Auth0
                .webAuth()
                .responseType([ResponseType.token])
                .scope("openid profile email offline_access")
                .audience("http://google_api")
                .connection("google-oauth2")
                .start {
                    switch $0 {
                    case .failure(let error):
                        // Handle the error
                        os_log("Failed to login with auth0, got error: %{public}@", "\(error)")
                        observer.on(.error(error))
                    case .success(let credentials):    
                        os_log("Store credentials with auth0 credentials manager.")
                        self.credentialsManager.store(credentials: credentials)
                        os_log("Successfully logged in with auth0, credentials: %{private}@", "\(credentials)")
                        
                        observer.on(.completed)
                    }
            }
            return Disposables.create()
        }
        
    }

}
