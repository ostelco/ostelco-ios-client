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
    
    func testMockCreatingCustomer() {
        self.stubPath("customer", toLoad: "customer_create")
        
        let setup = UserSetup(nickname: "HomerJay", email: "h.simpson@snpp.com")
        
        guard let customer = self.mockAPI.createCustomer(with: setup).awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(customer.name, "HomerJay")
        XCTAssertEqual(customer.email, "h.simpson@snpp.com")
        XCTAssertEqual(customer.id, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
        XCTAssertEqual(customer.analyticsId, "42b7d480-f434-4074-9f5c-2bf152f96cfe")
        XCTAssertEqual(customer.referralId, "b18635c0-f504-47ab-9d09-a425f615d2ae")
    }
    
    func testMockDeletingCustomer() {
        self.stubEmptyDataAtPath("customer", statusCode: 204)
       
        // Failures handled in `awaitResult`
        self.mockAPI.deleteCustomer().awaitResult(in: self)
    }
    
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
    
    func testMockNRICCheckWithValidNRIC() {
        self.stubPath("regions/sg/kyc/dave/S9315107J", toLoad: "nric_check_valid")
        
        guard let isValid = self.mockAPI.validateNRIC("S9315107J", forRegion: "sg").awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertTrue(isValid)
    }
    
    func testMockNRICCheckWithInvalidNRIC() {
        self.stubPath("regions/sg/kyc/dave/NOPE", toLoad: "nric_check_invalid", statusCode: 403)
        
        guard let isValid = self.mockAPI.validateNRIC("NOPE", forRegion: "sg").awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertFalse(isValid)
    }
    
    func testMockNRIC500Error() {
        self.stubEmptyDataAtPath("regions/sg/kyc/dave/NOPE", statusCode: 500)

        guard let error = self.mockAPI.validateNRIC("NOPE", forRegion: "sg").awaitResultExpectingError(in: self) else {
            // Unexpected success handled in `awaitResult`
            return
        }
        
        switch error {
        case APIHelper.Error.invalidResponseCode(let code, let data):
            XCTAssertEqual(code, 500)
            XCTAssertTrue(data.isEmpty)
        default:
            XCTFail("Unexpected error: \(error)")
        }
    }
    
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
        XCTAssertEqual(info.address.unit, "128")
        XCTAssertEqual(info.address.street, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(info.address.block, "102")
        XCTAssertEqual(info.address.postal, "460102")
        XCTAssertEqual(info.address.floor, "09")
        XCTAssertEqual(info.address.building, "PEARL GARDEN")
    }
    
    func testMockCreatingAddress() {
        let address = EKYCAddress(floor: "123",
                                  unit: "3",
                                  block: "123",
                                  building: "32",
                                  street: "123 Fake Street",
                                  postcode: "12345")
        
        self.stubEmptyDataAtAbsolutePath("regions/sg/kyc/profile?address=123;;;3;;;123;;;32;;;123%20Fake%20Street;;;12345", statusCode: 204)
        
        // Failure handled in `awaitResult`
        self.mockAPI.addAddress(address, forRegion: "sg").awaitResult(in: self)
    }
    
    func testMockUpdatingAddress() {
        guard
            let testInfo = MyInfoDetails.testInfo,
            let update = EKYCProfileUpdate(myInfoDetails: testInfo)else {
                XCTFail("Couldn't load test info details or create update!")
                return
        }
        self.stubEmptyDataAtAbsolutePath("regions/sg/kyc/profile?address=%2309-128,%20102%20PEARL%20GARDEN%0ABEDOK%20NORTH%20AVENUE%204,%20460102", statusCode: 204)
        
        self.mockAPI.updateEKYCProfile(with: update, forRegion: "sg").awaitResult(in: self)
    }
    
    func testMockCreatingJumioScan() {
        self.stubPath("regions/sg/kyc/jumio/scans", toLoad: "create_jumio_scan")
        
        guard let scan = self.mockAPI.createJumioScanForRegion(code: "sg").awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(scan.scanId, "326aceb6-3e54-4049-9f7b-0c922ad2c85a")
        XCTAssertEqual(scan.countryCode, "sg")
        XCTAssertEqual(scan.status, .PENDING)
    }
    
    func testMockRequestingSimProfile() {
       self.stubAbsolutePath("regions/sg/simProfiles?profileType=TEST",
                                   toLoad: "create_sim_profile")
        
        guard let simProfile = self.mockAPI.createSimProfileForRegion(code: "sg").awaitResult(in: self) else {
            // Failures handled by `awaitResult`
            return
        }
        
        XCTAssertEqual(simProfile.iccId, "8947000000000001598")
        XCTAssertEqual(simProfile.eSimActivationCode, "FAKE_ACTIVATION_CODE")
        XCTAssertEqual(simProfile.status, .AVAILABLE_FOR_DOWNLOAD)
        XCTAssertEqual(simProfile.alias, "")
    }
}
