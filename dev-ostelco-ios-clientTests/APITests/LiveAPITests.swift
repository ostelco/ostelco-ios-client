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
            print("Not running live tests without a logged in user!")
            return
        }
        
        self.liveFetchingContext()
        self.liveValidNRIC()
        self.liveInvalidNRIC()
        self.liveBundles()
        self.livePurchases()
        self.liveProducts()
        self.liveRegions()
        self.liveRegionWithData()
        self.liveUnsupportedRegion()
    }

    func liveFetchingContext() {
        guard let context = self.testAPI.loadContext().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertNotNil(context.customer)
        XCTAssertNotNil(context.regions.first)
    }
    
    func liveValidNRIC() {
        guard let isValid = self.testAPI.validateNRIC("S9315107J", forRegion: "sg").awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertTrue(isValid)
    }
    
    func liveInvalidNRIC() {
        guard let isValid = self.testAPI.validateNRIC("UNIT_TESTS", forRegion: "sg").awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertFalse(isValid)
    }
    
    func liveBundles() {
        // Failures handled in `awaitResult`
        _ = self.testAPI.loadBundles().awaitResult(in: self)
    }
    
    func livePurchases() {
        // Failures handled in `awaitResult`
        _ = self.testAPI.loadPurchases().awaitResult(in: self)
    }
    
    func liveProducts() {
        // Failures handled in `awaitResult`
        _ = self.testAPI.loadProducts().awaitResult(in: self)
    }
    
    func liveRegions() {
        guard let regions = self.testAPI.loadRegions().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertTrue(regions.isNotEmpty)
    }
    
    func liveRegionWithData() {
        guard let region = self.testAPI.loadRegion(code: "sg").awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(region.region.id, "sg")
    }
    
    func liveUnsupportedRegion() {
        // Note: This should be updated if we ever support Vanuatu.
        guard let error = self.testAPI.loadRegion(code: "vu").awaitResultExpectingError(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        switch error {
        case APIHelper.Error.jsonError(let jsonError):
            XCTAssertEqual(jsonError.httpStatusCode, 404)
            XCTAssertEqual(jsonError.errorCode, "FAILED_TO_FETCH_REGIONS")
        default:
            XCTFail("Unexpected error fetching unsupportedRegion: \(error)")
        }
    }
}
