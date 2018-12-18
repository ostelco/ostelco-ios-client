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

let ostelcoAPI = OstelcoAPI()
let auth0API = Auth0API();

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
                    AppDelegate.shared.rootViewController.switchToLogout()
                    return .useThisResponse
                } else {
                    os_log("Repeat the original failed request.")
                    return .passTo(request.repeated())
                }
            })
        } else {
            AppDelegate.shared.rootViewController.switchToLogout()
            return .useThisResponse
        }
    }
}

func refreshTokenHandler(refreshToken: String?) -> Siesta.Request {
    // TODO: It seems like we send multiple requests to refresh access token if multiple APIs fail with 401. Verify and fix if that's the case.
    return auth0API.token.request(.post, json: ["grant_type": "refresh_token", "client_id": Environment().configuration(.Auth0ClientID), "refresh_token": refreshToken])
        .onSuccess() {
            let credentials = $0.typedContent()! as Credentials
            let accessToken = credentials.accessToken;
            ostelcoAPI.authToken = "Bearer \(accessToken!)"
            // Credentials only contains accessToken at this point, if saved, we overwrite all other informatmion required by auth0 to validate the credentials, thus the user is presented with the login screen. Downside of not updating the accessToken with auth0 is that auth0 will again refresh the access token next time you open the app or the app comes into forground from background.
            // sharedAuth.credentialsManager.store(credentials: credentials)
            os_log("Successfully fetched new access token.")
    }
}

// TODO: Refactor to separate file, could also move the refresh token functions above inside the Auth0API class
class Auth0API: Service {
    fileprivate init() {
        #if DEBUG
            SiestaLog.Category.enabled = .all
        #endif
        
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

class OstelcoAPI: Service {
    
    fileprivate init() {
        #if DEBUG
            SiestaLog.Category.enabled = .all
        #endif
        
        super.init(
            baseURL: Environment().configuration(PlistKey.ServerURL),
            standardTransformers: [.text, .image]
        )
        
        configure {
            $0.headers["Content-Type"] = "application/json"
            $0.headers["Authorization"] = self.authToken
            
            $0.decorateRequests { res,req in
                return refreshTokenOnAuthFailure(request: req, refreshToken: self.refreshToken)
            }
        }
        
        let jsonDecoder = JSONDecoder()
        self.configureTransformer("/bundles") {
            try jsonDecoder.decode([BundleModel].self, from: $0.content)
        }
        
        self.configure("/bundles") {
            $0.expirationTime = 5
        }
        
        self.configureTransformer("/profile") {
            try jsonDecoder.decode(ProfileModel.self, from: $0.content)
        }
        
        self.configureTransformer("/purchases*") {
            try jsonDecoder.decode([PurchaseModel].self, from: $0.content)
        }
        
        self.configureTransformer("/products") {
            try jsonDecoder.decode([ProductModel].self, from: $0.content)
        }

        self.configureTransformer("/customer/new-ekyc-scanId") {
            try jsonDecoder.decode(ScanInformation.self, from: $0.content)
        }

    }
    
    var bundles: Resource { return resource("/bundles") }
    var profile: Resource { return resource("/profile") }
    var purchases: Resource { return resource("/purchases") }
    var products: Resource { return resource("/products") }
    var scanInformation: Resource { return resource("/customer/new-ekyc-scanId") }

    var authToken: String? {
        didSet {
            // Rerun existing configuration closure using new value
            invalidateConfiguration()
            
            // Wipe any cached state if auth token changes
            // Note: If we wipe resources, the purchase history list becomes blank after we repeate a request after a 401 from ostelcoAPI
            // wipeResources()
        }
    }
    
    var refreshToken: String?
}
