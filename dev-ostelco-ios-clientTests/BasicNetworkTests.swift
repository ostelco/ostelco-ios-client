//
//  BasicNetworkTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/13/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import OHHTTPStubs
@testable import ostelco_core
import XCTest

class BasicNetworkTests: XCTestCase {
    
    private lazy var basicNetwork = BasicNetwork()
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        self.setupStubbing()
    }
    
    override func tearDown() {
        self.tearDownStubbing()
        super.tearDown()
    }

    func testBadHeadersCauseRequestRejection() {
        let request = Request(baseURL: self.baseURL,
                              path: "foo",
                              loggedIn: true,
                              token: nil)
        
        guard let error = self.basicNetwork.performRequest(request).awaitResultExpectingError(in: self) else {
            // Unexpected success handled in `awaitResult`
            return
        }
        
        switch error {
        case Headers.Error.noTokenForLoggedInRequest:
            // This is what we want!
            break
        default:
            XCTFail("Unexpected error getting request rejected: \(error)")
        }
    }
    
    func testValidatingNoDataPassesWhenItsAllowed() {
        self.stubEmptyDataAtPath("foo", statusCode: 201)
        let request = Request(baseURL: self.baseURL,
                              path: "foo",
                              loggedIn: false,
                              token: nil)
        guard let data = self.basicNetwork.performValidatedRequest(request,
                                                  decoder: JSONDecoder(),
                                                  dataCanBeEmpty: true)
            .awaitResult(in: self) else {
                // Failure handled in `awaitResult`
                return
        }

        XCTAssertTrue(data.isEmpty)
        
    }
    
    func testValidatingNoDataFailsWhenItsNotAllowed() {
        self.stubEmptyDataAtPath("foo", statusCode: 201)
        let request = Request(baseURL: self.baseURL,
                              path: "foo",
                              loggedIn: false,
                              token: nil)
        guard let error = self.basicNetwork.performValidatedRequest(request, decoder: JSONDecoder()).awaitResultExpectingError(in: self) else {
                // Unexpected success handled in `awaitResult`
                return
        }
        
        switch error {
        case APIHelper.Error.dataWasEmpty:
            // This is what we're looking for!
            break
        default:
            XCTFail("Error for unexpected empty data was incorrect: \(error)")
        }
    }
}
