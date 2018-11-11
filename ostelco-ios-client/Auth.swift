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
import Bugsee

let sharedAuth = Auth()

enum AuthError: Error {
    case missingCredentials
    case missingAccessTokenInCredentials
    case missingRefreshTokenInCredentials
}


class Auth {
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    func clear() {
        os_log("Clear credentials in auth0 credentials manager.")
        self.credentialsManager.clear()
    }
    
    func logout() {
        os_log("Logout user")
        self.clear()
        AppDelegate.shared.rootViewController.switchToLogout()
    }
    
    func loginWithAuth0() -> Observable<Credentials> {
        os_log("Start login with auth0...")
        var params: [String:String] = ["primaryColor": "#\(ThemeManager.currentTheme().mainColor.toHex!)", "logo": Environment().configuration(.Auth0LogoURL)]
        return Observable.create { observer in
            Auth0
                .webAuth()
                .logging(enabled: true)
                .audience("http://google_api")
                .scope("openid email profile offline_access")
                // .connection("google-oauth2")
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
                        self.credentialsManager.store(credentials: credentials)
                        os_log("Successfully logged in with auth0, credential. refreshToken: %{private}@ accessToken: %{private}@ idToken: %{private}@", credentials.refreshToken ?? "none", credentials.accessToken ?? "none", credentials.idToken ?? "none")
                        observer.on(.next(credentials))
                        observer.on(.completed)
                    }
            }
            return Disposables.create()
        }
        
    }
    
    func verifyCredentials(completion: @escaping (Bool) -> Void ) {
        sharedAuth.credentialsManager.credentials { error, credentials in
            if let error = error {
                Bugsee.logError(error: error)
            } else {
                if let credentials = credentials {
                    if let accessToken = credentials.accessToken {
                        Bugsee.trace(key: "hasAccessToken", value: true)
                        DispatchQueue.main.async {
                            if (ostelcoAPI.authToken != accessToken && ostelcoAPI.authToken != nil) {
                                ostelcoAPI.wipeResources()
                            }
                            
                            if (ostelcoAPI.authToken != accessToken) {
                                ostelcoAPI.authToken = "Bearer \(accessToken)"
                            }
                            
                            if let refreshToken = credentials.refreshToken {
                                Bugsee.trace(key: "hasRefreshToken", value: true)
                                ostelcoAPI.refreshToken = refreshToken
                            } else {
                                Bugsee.trace(key: "hasRefreshToken", value: false)
                                Bugsee.logError(error: AuthError.missingRefreshTokenInCredentials)
                            }
                        }
                        completion(true)
                        return
                    } else {
                        Bugsee.trace(key: "hasAccessToken", value: false)
                        Bugsee.logError(error: AuthError.missingAccessTokenInCredentials)
                    }
                } else {
                    Bugsee.logError(error: AuthError.missingCredentials)
                }
            }
        }
        completion(false)
    }

}
