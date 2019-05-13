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
            if ProcessInfo.processInfo.environment["CIRCLECI"] == "true" {
                print("Not running live tests on the server where we can't log in!")
            } else {
                XCTFail("You should have a logged in user on your sim or device to run these tests locally!\n\nENV: \(ProcessInfo.processInfo.environment)")
            }
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
