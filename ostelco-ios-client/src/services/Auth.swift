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

    // force show the login screen after user logs out without using the auth0 logout url
    var forceLoginPrompt = false
    func clear() {
        os_log("Clear credentials in auth0 credentials manager.")
        Auth0
            .webAuth()
            .clearSession(federated: true) {
                print("Clear Session: ", $0)
                _ = self.credentialsManager.clear()
        }
    }

    func logout() {
        os_log("Logout user")
        self.clear()
        forceLoginPrompt = true
        OnBoardingManager.sharedInstance.region = nil
        UserManager.sharedInstance.user = nil
        // AppDelegate.shared.rootViewController.switchToLogout() // Old way of logging out
    }

    func loginWithAuth0() -> Observable<Credentials> {
        os_log("Start login with auth0...")
        var params: [String:String] = [:]

        if forceLoginPrompt {
            params["prompt"] = "login"
        }

        return Observable.create { observer in
            Auth0
                .webAuth()
                .logging(enabled: true)
                .audience("http://google_api")
                .scope("openid email profile offline_access")
                .parameters(params)
                .start {
                    switch $0 {
                    case .failure(let error):
                        // Handle the error
                        if let err = error as? WebAuthError {
                            switch err.errorCode {
                            case WebAuthError.userCancelled.errorCode:
                                observer.on(.completed)
                                break
                            default:
                                os_log("Failed to login with auth0, got error: %{public}@", "\(error)")
                                observer.on(.error(error))
                            }
                        } else {
                            os_log("Failed to login with auth0, got non web auth error: %{public}@", "\(error)")
                            observer.on(.error(error))
                        }

                    case .success(let credentials):
                        os_log("Store credentials with auth0 credentials manager.")
                        _ = self.credentialsManager.store(credentials: credentials)
                        os_log("Successfully logged in with auth0, credential. refreshToken: %{private}@ accessToken: %{private}@ idToken: %{private}@", credentials.refreshToken ?? "none", credentials.accessToken ?? "none", credentials.idToken ?? "none")
                        if let accessToken = credentials.accessToken {
                            DispatchQueue.main.async {
                                APIManager.sharedInstance.authHeader = "Bearer \(accessToken)"
                                UserManager.sharedInstance.authToken = accessToken
                            }
                        } else {
                            // TODO: How do we handle the case if access token is empty
                        }

                        self.forceLoginPrompt = false
                        observer.on(.next(credentials))
                        observer.on(.completed)
                    }
            }
            return Disposables.create()
        }
        
    }

}
