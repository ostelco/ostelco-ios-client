//
//  MockAPITests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
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
    
    // MARK: - Push
    
    func testMockSendingPushNotificationToken() {
        self.stubPath("applicationToken", toLoad: "send_push_token")
        
        let pushToken = PushToken(token: "diY18Uy_xDI:APA91bFNqZ-UWLSS9SYZLYGh2UuTHiyBitBLDQ15dEyOLHMIXsmSUc07_kUgV3ir7yolUEr-44x1gA-u_oQ9964KbmXMG-SO7E9y1ruJGd205bsq7Lk2D-2uhKgIChYgN22_DSC9hK_5",
                                  tokenType: "FCM",
                                  applicationID: "sg.redotter.dev.selfcare.9725FE65-45FD-4646-B8A3-FF20ADEBF509")
        
        // Failures handled in `awaitResult`
        self.mockAPI.sendPushToken(pushToken).awaitResult(in: self)
    }
    
    // MARK: - Bundles
    
    func testMockLoadingBundles() {
        self.stubPath("bundles", toLoad: "bundles")
        
        guard let bundles = self.mockAPI.loadBundles().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(bundles.count, 1)
    
        guard let bundle = bundles.first else {
            XCTFail("Couldn't access first bundle!")
            return
        }
        
        XCTAssertEqual(bundle.id, "0c95007b-fcc2-48f9-a889-5eade089b9b3")
        XCTAssertEqual(bundle.balance, 2147483648)
    }
    
    // MARK: - Context
    
    func testMockFetchingContextForUserWithoutCustomerProfile() {
        self.stubPath("context", toLoad: "customer_nonexistent", statusCode: 404)
        
        guard let error = self.mockAPI.loadContext().awaitResultExpectingError(in: self) else {
            // Unexpected success handled in `awaitResult`
            return
        }
        
        switch error {
        case APIHelper.Error.jsonError(let jsonError):
            XCTAssertEqual(jsonError.errorCode, "FAILED_TO_FETCH_CONTEXT")
            XCTAssertEqual(jsonError.httpStatusCode, 404)
            XCTAssertEqual(jsonError.message, "Failed to fetch customer.")
        default:
            XCTFail("Unexpected error type received: \(error)")
        }
    }
    
    func testMockFetchingContextForUserWhoAlreadyHasCustomerProfileButNotRegions() {
        self.stubPath("context", toLoad: "context_no_regions")
        
        guard let context = self.mockAPI.loadContext().awaitResult(in: self) else {
            // Failure handled in `awaitResult`
            return
        }
        
        guard let customer = context.customer else {
            XCTFail("No customer in context!")
            return
        }
        
        XCTAssertEqual(customer.name, "HomerJay")
        XCTAssertEqual(customer.email, "h.simpson@snpp.com")
        XCTAssertEqual(customer.id, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
        XCTAssertEqual(customer.analyticsId, "42b7d480-f434-4074-9f5c-2bf152f96cfe")
        XCTAssertEqual(customer.referralId, "b18635c0-f504-47ab-9d09-a425f615d2ae")
        
        XCTAssertEqual(context.regions.count, 0)
        XCTAssertNil(context.getRegion())
    }
    
    func testMockFetchingContextForUserWhoAlreadyHasCustomerProfileAndRegionsJumioRejected() {
        self.stubPath("context", toLoad: "context_jumio_rejected")
        
        guard let context = self.mockAPI.loadContext().awaitResult(in: self) else {
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
    
    func testMockFetchingContextForUserWhoAlreadyHasCustomerProfileAndRegionsJumioApproved() {
        self.stubPath("context", toLoad: "context_jumio_approved")
        
        guard let context = self.mockAPI.loadContext().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        guard let customer = context.customer else {
            XCTFail("Couldn't access customer!")
            return
        }
        
        XCTAssertEqual(customer.name, "HomerJay")
        XCTAssertEqual(customer.email, "h.simpson@snpp.com")
        XCTAssertEqual(customer.id, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
        XCTAssertEqual(customer.analyticsId, "42b7d480-f434-4074-9f5c-2bf152f96cfe")
        XCTAssertEqual(customer.referralId, "b18635c0-f504-47ab-9d09-a425f615d2ae")
        
        guard let region = context.getRegion() else {
            XCTFail("Could not get region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "sg")
        XCTAssertEqual(region.region.name, "Singapore")
        XCTAssertEqual(region.status, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.JUMIO, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.MY_INFO, .PENDING)
        XCTAssertEqual(region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.NRIC_FIN, .APPROVED)
        
        guard let simProfiles = region.simProfiles else {
            XCTFail("Sim profiles was unexpectedly nil!")
            return
        }
        
        XCTAssertEqual(simProfiles.count, 0)
    }
    
    func testMockFetchingContextForUserWithValidSimProfile() {
        self.stubPath("context", toLoad: "context_with_sim_profile")
        
        guard let context = self.mockAPI.loadContext().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        guard let customer = context.customer else {
            XCTFail("Couldn't access customer!")
            return
        }
        
        XCTAssertEqual(customer.name, "HomerJay")
        XCTAssertEqual(customer.email, "h.simpson@snpp.com")
        XCTAssertEqual(customer.id, "5112d0bf-4f58-49ea-b417-2af8d69895d2")
        XCTAssertEqual(customer.analyticsId, "42b7d480-f434-4074-9f5c-2bf152f96cfe")
        XCTAssertEqual(customer.referralId, "b18635c0-f504-47ab-9d09-a425f615d2ae")
        
        guard let region = context.getRegion() else {
            XCTFail("Could not get region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "sg")
        XCTAssertEqual(region.region.name, "Singapore")
        XCTAssertEqual(region.status, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.JUMIO, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.MY_INFO, .PENDING)
        XCTAssertEqual(region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.NRIC_FIN, .APPROVED)
        
        guard let simProfile = region.getSimProfile() else {
            XCTFail("Could not get sim profile from region!")
            return
        }
        
        XCTAssertEqual(simProfile.iccId, "8947000000000001598")
        XCTAssertEqual(simProfile.eSimActivationCode, "FAKE_ACTIVATION_CODE")
        XCTAssertEqual(simProfile.status, .AVAILABLE_FOR_DOWNLOAD)
        XCTAssertEqual(simProfile.alias, "")
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
    
    // MARK: - Products
    
    func testMockLoadingProducts() {
        self.stubPath("products", toLoad: "products")
        
        guard let products = self.mockAPI.loadProducts().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(products.count, 1)
        
        guard let product = products.first else {
            XCTFail("Could not access first product!")
            return
        }
        
        XCTAssertEqual(product.sku, "PLAN_1SGD_YEAR")
        
        XCTAssertEqual(product.price.amount, 100)
        XCTAssertEqual(product.price.currency, "SGD")
        
        XCTAssertEqual(product.properties, [
            "intervalCount": "1",
            "productClass": "PLAN",
            "interval": "year"
        ])
        
        XCTAssertEqual(product.presentation.price, "$1")
        XCTAssertEqual(product.presentation.label, "Annual subscription plan")
    }
    
    // MARK: - Purchases
    
    func testMockLoadingPurchases() {
        self.stubPath("purchases", toLoad: "purchases")
        
        guard let purchases = self.mockAPI.loadPurchases().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(purchases.count, 1)
        
        guard let purchase = purchases.first else {
            XCTFail("Couldn't load first purchase!")
            return
        }
        
        XCTAssertEqual(purchase.id, "84407440-6441-4c31-814e-603b2921296a")
        XCTAssertEqual(purchase.timestamp, 1557740624128)
        
        XCTAssertEqual(purchase.product.sku, "2GB_FREE_ON_JOINING")
        
        XCTAssertEqual(purchase.product.price.amount, 0)
        XCTAssertEqual(purchase.product.price.currency, "")
        
        XCTAssertEqual(purchase.product.properties, [
            "noOfBytes": "2_147_483_648",
            "productClass": "SIMPLE_DATA"
        ])
        
        XCTAssertEqual(purchase.product.presentation.price, "Free")
        XCTAssertEqual(purchase.product.presentation.label, "2GB Welcome Pack")
    }
    
    // MARK: - Regions
    
    func testMockLoadingAllRegions() {
        self.stubPath("regions", toLoad: "regions")
        
        guard let regions = self.mockAPI.loadRegions().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        guard let region = regions.first else {
            XCTFail("Could not get region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "sg")
        XCTAssertEqual(region.region.name, "Singapore")
        XCTAssertEqual(region.status, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.JUMIO, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.MY_INFO, .PENDING)
        XCTAssertEqual(region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.NRIC_FIN, .APPROVED)
        
        guard let simProfile = region.getSimProfile() else {
            XCTFail("Could not get sim profile from region!")
            return
        }
        
        XCTAssertEqual(simProfile.iccId, "8947000000000001598")
        XCTAssertEqual(simProfile.eSimActivationCode, "FAKE_ACTIVATION_CODE")
        XCTAssertEqual(simProfile.status, .AVAILABLE_FOR_DOWNLOAD)
        XCTAssertEqual(simProfile.alias, "")
    }
    
    func testMockLoadingRegionFromRegions() {
        self.stubPath("regions", toLoad: "regions_multiple")
        
        guard let approvedRegion = self.mockAPI.getRegionFromRegions().awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(approvedRegion.region.id, "no")
        XCTAssertEqual(approvedRegion.region.name, "Norway")
        XCTAssertEqual(approvedRegion.status, .APPROVED)
        
        XCTAssertNil(approvedRegion.kycStatusMap.ADDRESS_AND_PHONE_NUMBER)
        XCTAssertNil(approvedRegion.kycStatusMap.JUMIO)
        XCTAssertNil(approvedRegion.kycStatusMap.MY_INFO)
        XCTAssertNil(approvedRegion.kycStatusMap.NRIC_FIN)
        
        guard let simProfiles = approvedRegion.simProfiles else {
            XCTFail("Sim profiles was nil when it shouldn't be!")
            return
        }
        
        XCTAssertTrue(simProfiles.isEmpty)
    }
    
    func testMockLoadingSingleSupportedRegion() {
        self.stubPath("regions/sg", toLoad: "region_singapore")
        
        guard let region = self.mockAPI.loadRegion(code: "sg").awaitResult(in: self) else {
            // Failures handled by `awaitResult`
            return
        }
        
        XCTAssertEqual(region.region.id, "sg")
        XCTAssertEqual(region.region.name, "Singapore")
        XCTAssertEqual(region.status, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.JUMIO, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.MY_INFO, .PENDING)
        XCTAssertEqual(region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, .APPROVED)
        XCTAssertEqual(region.kycStatusMap.NRIC_FIN, .APPROVED)
        
        guard let simProfile = region.getSimProfile() else {
            XCTFail("Could not get sim profile from region!")
            return
        }
        
        XCTAssertEqual(simProfile.iccId, "8947000000000001598")
        XCTAssertEqual(simProfile.eSimActivationCode, "FAKE_ACTIVATION_CODE")
        XCTAssertEqual(simProfile.status, .AVAILABLE_FOR_DOWNLOAD)
        XCTAssertEqual(simProfile.alias, "")
    }
    
    func testMockLoadingSingleUnsupportedRegion() {
        self.stubPath("regions/vu", toLoad: "region_vanuatu", statusCode: 404)
        guard let error = self.mockAPI.loadRegion(code: "vu").awaitResultExpectingError(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        switch error {
        case APIHelper.Error.jsonError(let jsonError):
            XCTAssertEqual(jsonError.httpStatusCode, 404)
            XCTAssertEqual(jsonError.errorCode, "FAILED_TO_FETCH_REGIONS")
            XCTAssertEqual(jsonError.message, "Failed to get regions.")
        default:
            XCTFail("Unexpected error fetching unsupportedRegion: \(error)")
        }
    }
    
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
    
    func testMockCreatingAddress() {
        let address = EKYCAddress(street: "123 Fake Street",
                                  unit: "3",
                                  city: "Fake City",
                                  postcode: "12345",
                                  country: "Singapore")
        
        self.stubEmptyDataAtAbsolutePath("regions/sg/kyc/profile?address=123%20Fake%20Street;;;3;;;Fake%20City;;;12345;;;Singapore&phoneNumber=12345678", statusCode: 204)
        
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
        self.stubEmptyDataAtAbsolutePath("regions/sg/kyc/profile?address=102%20BEDOK%20NORTH%20AVENUE%204%0A460102%20SG&phoneNumber=+6597399245", statusCode: 204)
        
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
        XCTAssertEqual(scan.status, "PENDING")
    }
    
    func testMockRequestingSimProfile() {
       self.stubAbsolutePath("regions/sg/simProfiles?profileType=iphone",
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
    
    func testMockRequestingSimProfilesForRegion() {
        self.stubPath("regions/sg/simprofiles", toLoad: "sim_profiles_singapore")
        
        guard let simProfiles = self.mockAPI.loadSimProfilesForRegion(code: "sg").awaitResult(in: self) else {
            // Failures handled in `awaitResult`
            return
        }
        
        XCTAssertEqual(simProfiles.count, 1)
        
        guard let simProfile = simProfiles.first else {
            XCTFail("Could not access first sim profile!")
            return
        }
        
        XCTAssertEqual(simProfile.iccId, "8947000000000001598")
        XCTAssertEqual(simProfile.eSimActivationCode, "FAKE_ACTIVATION_CODE")
        XCTAssertEqual(simProfile.status, .DOWNLOADED)
        XCTAssertEqual(simProfile.alias, "")
    }
}
