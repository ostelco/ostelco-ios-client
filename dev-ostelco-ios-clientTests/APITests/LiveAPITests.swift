//
//  LiveAPITests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import XCTest

class LiveAPITests: XCTestCase {
    
    private lazy var testAPI = APIManager.shared.primeAPI
    
    func testLiveIfTheresAUser() {
        guard UserManager.shared.firebaseUser != nil else {
            print("Not running live tests without a user!")
            return
        }
        
        self.liveFetchingContext()
    }

    func liveFetchingContext() {
        guard let context = self.testAPI.loadContext().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertNotNil(context.customer)
        XCTAssertNotNil(context.regions.first)
    }
    
}
