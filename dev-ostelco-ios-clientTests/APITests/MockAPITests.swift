//
//  MockAPITests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import XCTest

class MockAPITests: XCTestCase {
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        self.setupStubbing()
    }
    
    override func tearDown() {
        self.tearDownStubbing()
        super.tearDown()
    }
    
    // MARK: - Customer
    
    func testMockCreatingEphemeralKey() {
        self.stubAbsolutePath("customer/stripe-ephemeral-key?api_version=2015-10-12", toLoad: "stripe_ephemeral_key")
        
        let request = StripeEphemeralKeyRequest(apiVersion: "2015-10-12")
        
        guard let keyDict = self.mockAPI.stripeEphemeralKey(with: request).awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(keyDict["id"] as? String, "ephkey_FAKE")
        XCTAssertEqual(keyDict["object"] as? String, "ephemeral_key")
        XCTAssertEqual(keyDict["created"] as? Int64, Int64(1557842380))
        XCTAssertEqual(keyDict["expires"] as? Int64, Int64(1557845980))
        XCTAssertEqual(keyDict["livemode"] as? Bool, true)
        XCTAssertEqual(keyDict["secret"] as? String, "ek_live_FAKE")
        
        guard let associatedObjects = keyDict["associated_objects"] as? [[String: AnyHashable]] else {
            XCTFail("Couldn't get associated objects")
            return
        }
        
        XCTAssertEqual(associatedObjects.count, 1)
        guard let firstObject = associatedObjects.first else {
            XCTFail("Couldn't get first associated object")
            return
        }
        
        XCTAssertEqual(firstObject["type"] as? String, "customer")
        XCTAssertEqual(firstObject["id"] as? String, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
    }
    
    func testMockBadDataForEphemeralKey() {
        self.stubAbsolutePath("customer/stripe-ephemeral-key?api_version=INVALID", toLoad: "stripe_key_invalid")
        
        let request = StripeEphemeralKeyRequest(apiVersion: "INVALID")
        
        guard let error = self.mockAPI.stripeEphemeralKey(with: request).awaitResultExpectingError(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        switch error {
        case APIHelper.Error.unexpectedResponseFormat(let data):
            XCTAssertTrue(data.isNotEmpty)
        default:
            XCTFail("Unexpected error type for bad data with ephemeral key: \(error)")
        }
    }
    
    // MARK: - Regions
    
    func testMockFetchingMyInfoConfig() {
        self.stubPath("regions/sg/kyc/myInfo/v3/config", toLoad: "my_info_config")
        
        guard let config = self.mockAPI.loadMyInfoConfig().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(config.url, "https://myinfosgstg.api.gov.sg/test/v2/authorise?client_id=STG-FAKE_CLIENT_ID&attributes=name,sex,dob,residentialstatus,nationality,mobileno,email,mailadd&redirect_uri=https://dl-dev.oya.world/links/myinfo")
    }
    
    func testMockFetchingMyInfo() {
        self.stubPath("regions/sg/kyc/myInfo/v3/personData/some-singpass-code", toLoad: "my_info")
        
        guard let info = self.mockAPI.loadSingpassInfo(code: "some-singpass-code").awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(info.name, "TAN XIAO HUI")
        XCTAssertEqual(info.dob, "1998-06-06")
        XCTAssertEqual(info.email, "myinfotesting@gmail.com")
        XCTAssertEqual(info.nationality, "SG")
        XCTAssertEqual(info.residentialStatus, "C")
        XCTAssertEqual(info.sex, "F")
        
        XCTAssertEqual(info.address.country, "SG")
        XCTAssertEqual(info.address.unit, "128")
        XCTAssertEqual(info.address.street, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(info.address.block, "102")
        XCTAssertEqual(info.address.postal, "460102")
        XCTAssertEqual(info.address.floor, "09")
        XCTAssertEqual(info.address.building, "PEARL GARDEN")
        
        guard let mobileNumber = info.mobileNumber else {
            XCTFail("Could not access mobile number!")
            return
        }
        
        XCTAssertEqual(mobileNumber.prefix, "+")
        XCTAssertEqual(mobileNumber.code, "65")
        XCTAssertEqual(mobileNumber.number, "97399245")
        XCTAssertEqual(mobileNumber.formattedNumber, "+6597399245")
    }
    
    func testMockUpdatingAddress() {
        guard
            let testInfo = MyInfoDetails.testInfo,
            let update = EKYCProfileUpdate(myInfoDetails: testInfo)else {
                XCTFail("Couldn't load test info details or create update!")
                return
        }
        self.stubEmptyDataAtAbsolutePath("regions/sg/kyc/profile?address=102%20BEDOK%20NORTH%20AVENUE%204%0A460102%20SG&phoneNumber=+6597399245", statusCode: 204)
        
        self.mockAPI.updateEKYCProfile(with: update, forRegion: "sg").awaitResult(in: self)
    }
}
