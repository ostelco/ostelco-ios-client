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
        guard UserManager.shared.hasCurrentUser else {
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
        self.liveAddressUpdate()
        self.liveSimProfilesForRegion()
        self.liveStripeEphemeralKey()
        self.liveMyInfoConfig()
    }

    func liveFetchingContext() {
        guard let context = self.testAPI.loadContext().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertNotNil(context.customer)
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
    
    func liveAddressUpdate() {
        let address = MyInfoAddress(country: "SG",
                                    unit: "128",
                                    street: "BEDOK NORTH AVENUE 4",
                                    block: "102",
                                    postal: "460102",
                                    floor: "09",
                                    building: "PEARL GARDEN").formattedAddress
        let phone = "+6597399245"
        
        let update = EKYCProfileUpdate(address: address, phoneNumber: phone)
        
        // Failures handled in `awaitResult`
        self.testAPI.updateEKYCProfile(with: update, forRegion: "sg").awaitResult(in: self)
    }
    
    func liveSimProfilesForRegion() {
        // Failures handled in `awaitResult`
        _ = self.testAPI.loadSimProfilesForRegion(code: "sg").awaitResult(in: self)
    }
    
    func liveStripeEphemeralKey() {
        // API version can be found in Pods/Stripe/STPAPIClient
        // (near the top) -not public so can't be accessed directly
        let request = StripeEphemeralKeyRequest(apiVersion: "2015-10-12")
        
        guard let dictionary = self.testAPI.stripeEphemeralKey(with: request).awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertTrue(dictionary.isNotEmpty)
    }
    
    func liveMyInfoConfig() {
        guard let config = self.testAPI.loadMyInfoConfig().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }

        // Can we at least create a URL out of what we get back?
        XCTAssertNotNil(URL(string: config.url))
    }
}
