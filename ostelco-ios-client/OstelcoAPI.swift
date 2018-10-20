//
//  OstelcoAPI.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Siesta
import Foundation

let ostelcoAPI = OstelcoAPI()

class OstelcoAPI: Service {
    
    fileprivate init() {
        #if DEBUG
            SiestaLog.Category.enabled = .all
        #endif
        
        super.init(
            baseURL: "https://api.ostelco.org",
            standardTransformers: [.text, .image]
        )
        
        configure {
            $0.headers["Content-Type"] = "application/json"
            $0.headers["Authorization"] = self.authToken
            
            $0.decorateRequests { _, req in
                req.onFailure { error in                   // If a request fails...
                    if error.httpStatusCode == 401 {         // ...with a 401...
                        // TODO: Inform user that session has expired?
                        sharedAuth.logout()
                    }
                }
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
        
        self.configureTransformer("/purchases") {
            try jsonDecoder.decode([PurchaseModel].self, from: $0.content)
        }
        
        self.configureTransformer("/products") {
            try jsonDecoder.decode([ProductModel].self, from: $0.content)
        }
    }
    
    var bundles: Resource { return resource("/bundles") }
    var profile: Resource { return resource("/profile") }
    var purchases: Resource { return resource("/purchases") }
    var products: Resource { return resource("/products") }
    
    var authToken: String? {
        didSet {
            // Rerun existing configuration closure using new value
            invalidateConfiguration()
            
            // Wipe any cached state if auth token changes
            wipeResources()
        }
    }
}
