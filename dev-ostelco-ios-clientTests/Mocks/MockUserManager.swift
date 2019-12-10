//
//  MockUserManager.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/17/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
@testable import Oya_Development_app
import PromiseKit

class MockUserManager: UserManager {
    
    var tokenProvider = MockTokenProvider()
    var fakeEmail: String?
    var mockHasCurrentUser: Bool = true
    
    override var currentUserEmail: String? {
        return self.fakeEmail
    }
    
    override var hasCurrentUser: Bool {
        return self.mockHasCurrentUser
    }
    
    override func getToken() -> Promise<String> {
        return self.tokenProvider.getToken()
    }
    
    override func forceRefreshToken() -> Promise<String> {
        return self.tokenProvider.forceRefreshToken()
    }
}
