//
//  API.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Siesta

class APIManager: Service {
    
    static let sharedInstance = APIManager()
    let jsonDecoder = JSONDecoder()
    var authHeader: String? {
        didSet {
            invalidateConfiguration()
            wipeResources()
        }
    }
    
    var customer: Resource { return resource("/customer") }
    
    fileprivate init() {
        #if DEBUG
        SiestaLog.Category.enabled = .all
        #endif
        
        super.init(
            baseURL: Environment().configuration(PlistKey.ServerURL),
            standardTransformers: [.text]
        )
        
        configure {
            $0.headers["Content-Type"] = "application/json"
            $0.headers["Authorization"] = self.authHeader
        }
        
        configureTransformer("/customer") {
            try self.jsonDecoder.decode(CustomerModel.self, from: $0.content)
        }
    }
}
