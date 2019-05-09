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
    
    lazy var loggedInAPI: LoggedInAPI = {
        let baseURLString = Environment().configuration(PlistKey.ServerURL)
        return LoggedInAPI(baseURL: baseURLString,
                           tokenProvider: self.tokenProvider)
    }()
    
    var tokenProvider: TokenProvider = UserManager.sharedInstance

    fileprivate init() {
        URLSession.shared.configuration.timeoutIntervalForRequest = 300
    }
}
