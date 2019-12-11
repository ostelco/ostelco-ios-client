//
//  API.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit

class APIManager {
    
    static let shared = APIManager()
    
    lazy var primeAPI: PrimeAPI = {
        let baseURLString = EnvironmentPlist().configuration(PlistKey.ServerURL)
        return PrimeAPI(
            baseURLString: baseURLString,
            tokenProvider: self.tokenProvider
        )
    }()
    
    var baseURLString: String {
        return EnvironmentPlist().configuration(PlistKey.ServerURL)
    }
    
    var tokenProvider: TokenProvider = UserManager.shared

    fileprivate init() {
        URLSession.shared.configuration.timeoutIntervalForRequest = 300
    }
}
