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
        let auth0Storage = sharedAuth.credentialsSecureStorage
        return LoggedInAPI(baseURL: baseURLString,
                           secureStorage: auth0Storage)
    }()
    
    var authHeader: String? {
        didSet {
            invalidateConfiguration()
            wipeResources()
        }
    }
    
    var products: Resource { return resource("/products") }
    var regions: Resource { return resource("/regions") }

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
        
        configureTransformer("/regions/*/kyc/jumio/scans") {
            try self.jsonDecoder.decode(Scan.self, from: $0.content)
        }
        configureTransformer("/regions/*/simProfiles", requestMethods: [.post]) {
            try self.jsonDecoder.decode(SimProfile.self, from: $0.content)
        }
    }
}
