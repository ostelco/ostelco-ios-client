//
//  MockTokenProvider.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit
@testable import Oya_Development_app

class MockTokenProvider: TokenProvider {
    
    enum Error: Swift.Error {
        case initialTokenNotSet
        case refreshedTokenNotSet
    }
    
    var initialToken: String?
    var refreshedToken: String?
    
    func getToken() -> Promise<String> {
        guard let initial = self.initialToken else {
            return Promise(error: Error.initialTokenNotSet)
        }
        
        return .value(initial)
    }
    
    func forceRefreshToken() -> Promise<String> {
        guard let refreshed = self.refreshedToken else {
            return Promise(error: Error.refreshedTokenNotSet)
        }
        
        return .value(refreshed)
    }
}
