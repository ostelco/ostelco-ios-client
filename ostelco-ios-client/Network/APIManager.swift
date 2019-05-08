//
//  API.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import Siesta
import ostelco_core

class APIManager: Service {
    
    static let sharedInstance = APIManager()
    let jsonDecoder = JSONDecoder()
    
    lazy var loggedInAPI: LoggedInAPI = {
        let baseURLString = Environment().configuration(PlistKey.ServerURL)
        return LoggedInAPI(baseURL: baseURLString,
                           tokenProvider: self.tokenProvider)
    }()
    
    var authHeader: String? {
        didSet {
            invalidateConfiguration()
            wipeResources()
        }
    }
    
    var regions: Resource { return resource("/regions") }
    
    var tokenProvider: TokenProvider = UserManager.sharedInstance

    fileprivate init() {
        let networking = URLSessionConfiguration.ephemeral
        networking.timeoutIntervalForRequest = 300
        super.init(
            baseURL: Environment().configuration(PlistKey.ServerURL),
            standardTransformers: [.text],
            networking: networking
        )
        
        configure {
            $0.headers["Content-Type"] = "application/json"
            $0.headers["Authorization"] = self.authHeader
        }
        
        configureTransformer("/regions/*/simProfiles", requestMethods: [.post]) {
            try self.jsonDecoder.decode(SimProfile.self, from: $0.content)
        }
    }
}
