//
//  MockAPITests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OHHTTPStubs
import ostelco_core
import PromiseKit
import XCTest

class MockAPITests: XCTestCase {
    
    private lazy var testAPI = PrimeAPI(baseURL: "https://www.fake.org/api", tokenProvider: self.mockTokenProvider)
    
    private lazy var mockTokenProvider: MockTokenProvider = {
        let provider = MockTokenProvider()
        provider.initialToken = "Initial Test Token"
        return provider
    }()
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.setEnabled(true)
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        OHHTTPStubs.setEnabled(false)
        super.tearDown()
    }
    
    // MARK: - Test Helpers
    
    private func stubPath(_ path: String,
                          toLoad fileName: String,
                          statusCode: Int32 = 200,
                          file: StaticString = #file,
                          line: UInt = #line) {
        OHHTTPStubs.stubRequests(passingTest: isPath("/api/\(path)"), withStubResponse: { _ in
            guard let path = Bundle(for: MockAPITests.self).path(forResource: fileName, ofType: "json", inDirectory: "MockJSON") else {
                XCTFail("Couldn't get bundled path!",
                        file: file,
                        line: line)
                return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
            }
            
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: statusCode, headers: nil)
        })
    }
    
    func testMockFetchingContext() throws {
        self.stubPath("context", toLoad: "context")
        
        guard let context = self.testAPI.loadContext().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        guard let customer = context.customer else {
            XCTFail("No customer in context!")
            return
        }
        
        XCTAssertEqual(customer.id, "e30665f1-2a08-4304-bc06-5005b268b3b8")
        XCTAssertEqual(customer.analyticsId, "7966e40e-e85a-46fd-953d-14e86bb0afec")
        XCTAssertEqual(customer.referralId, "f3562c3a-8a6e-4be1-a521-7a2c7b1c2b41")
        XCTAssertEqual(customer.email, "steve@apple.com")
        XCTAssertEqual(customer.name, "Steve")
        XCTAssertFalse(customer.hasSubscription())
        
        XCTAssertEqual(context.regions.count, 1)

        guard let firstRegion = context.regions.first else {
            XCTFail("Context regions was empty!")
            return
        }
        
        XCTAssertEqual(firstRegion.region.id, "sg")
        XCTAssertEqual(firstRegion.region.name, "Singapore")
        XCTAssertEqual(firstRegion.status, .PENDING)
        XCTAssertEqual(firstRegion.kycStatusMap.JUMIO, .REJECTED)
        XCTAssertEqual(firstRegion.kycStatusMap.MY_INFO, .PENDING)
        XCTAssertEqual(firstRegion.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, .PENDING)
        XCTAssertEqual(firstRegion.kycStatusMap.NRIC_FIN, .APPROVED)
    
        guard let simProfiles = firstRegion.simProfiles else {
            XCTFail("Sim profiles was null instead of empty!")
            return
        }
        
        XCTAssertTrue(simProfiles.isEmpty)
    }
    
    // MARK: - Customer
    
    func testAddingCustomerNickname() {
        self.stubPath("customer", toLoad: "customer_create")
        
        let setup = UserSetup(nickname: "HomerJay", email: "h.simpson@snpp.com")
        
        guard let customer = self.testAPI.createCustomer(with: setup).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(customer.name, "HomerJay")
        XCTAssertEqual(customer.email, "h.simpson@snpp.com")
        XCTAssertEqual(customer.id, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
        XCTAssertEqual(customer.analyticsId, "42b7d480-f434-4074-9f5c-2bf152f96cfe")
        XCTAssertEqual(customer.referralId, "b18635c0-f504-47ab-9d09-a425f615d2ae")
    }
    
    func testMockDeletingCustomer() {
        OHHTTPStubs.stubRequests(passingTest: isPath("/api/customer") && isMethodDELETE(), withStubResponse: { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 204, headers: nil)
        })
        
        self.testAPI.deleteCustomer().awaitResult(in: self)
    }
}
