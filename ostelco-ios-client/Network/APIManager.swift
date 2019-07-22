//
//  API.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit

class APIManager {
    
    static let shared = APIManager()
    
    lazy var primeAPI: PrimeAPI = {
        let baseURLString = Environment().configuration(PlistKey.ServerURL)
        return PrimeAPI(baseURLString: baseURLString,
                           tokenProvider: self.tokenProvider)
    }()
    
    var baseURLString: String {
        return Environment().configuration(PlistKey.ServerURL)
    }
    
    var tokenProvider: TokenProvider = UserManager.shared

    fileprivate init() {
        URLSession.shared.configuration.timeoutIntervalForRequest = 300
    }
}
