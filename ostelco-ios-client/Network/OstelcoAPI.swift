//
//  OstelcoAPI.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Siesta
import Foundation
import os
import Auth0
import ostelco_core

let auth0API = Auth0API()

// var authRequest: Siesta.Request? = nil;
let serialQueue = DispatchQueue(label: "SerialQueue")

func refreshTokenOnAuthFailure(request: Siesta.Request, refreshToken: String?) -> Siesta.Request {
    // os_log("API failed with 401, most likely the access token has expired. Try to get a new access token using the refresh token.")
    return request.chained {
        // TODO: Why is the below line required?
        guard case .failure(let error) = $0.response, error.httpStatusCode == 401 || error.httpStatusCode == 400  else {
            os_log("Non 401 error, continue as normal")
            return .useThisResponse
        }
        
        if let refreshToken = refreshToken {
            os_log("Refresh access token...")
            return .passTo(refreshTokenHandler(refreshToken: refreshToken).chained {
                if case .failure = $0.response {
                    os_log("Failed to refresh access token. Should send user back to login screen.")
                    #warning("Switch back to login screen here")
                    return .useThisResponse
                } else {
                    os_log("Repeat the original failed request.")
                    return .passTo(request.repeated())
                }
            })
        } else {
            // AppDelegate.shared.rootViewController.switchToLogout()
            print("Your session has expired?")
            return .useThisResponse
        }
    }
}

func refreshTokenHandler(refreshToken: String?) -> Siesta.Request {
    // TODO: It seems like we send multiple requests to refresh access token if multiple APIs fail with 401. Verify and fix if that's the case.
    return auth0API.token.request(.post, json: ["grant_type": "refresh_token", "client_id": Environment().configuration(.Auth0ClientID), "refresh_token": refreshToken])
        .onSuccess {
            let credentials = $0.typedContent()! as Credentials
            guard let accessToken = credentials.accessToken else {
                assertionFailure("No access token?!")
                return
            }
            APIManager.sharedInstance.authHeader = "Bearer \(accessToken)"
            sharedAuth.credentialsSecureStorage.setString(accessToken, for: .Auth0Token)
            // Credentials only contains accessToken at this point, if saved, we overwrite all other informatmion required
            // by auth0 to validate the credentials, thus the user is presented with the login screen. Downside of not updating
            // the accessToken with auth0 is that auth0 will again refresh the access token next time you open the app or the
            // app comes into forground from background.
            // sharedAuth.credentialsManager.store(credentials: credentials)
            os_log("Successfully fetched new access token.")
    }
}

// TODO: Refactor to separate file, could also move the refresh token functions above inside the Auth0API class
class Auth0API: Service {
    fileprivate init() {
        super.init(
            baseURL: "https://\(Environment().configuration(.Auth0Domain))"
        )
        
        self.configure("oauth/token") {
            $0.headers["content-Type"] = "application/json"
        }
        
        self.configureTransformer("oauth/token") {
            Credentials(json: $0.content)
        }
    }
    
    var token: Resource { return resource("oauth/token") }
}
