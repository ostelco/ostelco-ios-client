//
//  RootCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class RootCoordinatorTests: XCTestCase {
    
    lazy var testUserManager = MockUserManager()
    
    lazy var testCoordinator = RootCoordinator(window: UIWindow(),
                                               userManager: self.testUserManager)
    
    override func setUp() {
        super.setUp()
        UserDefaultsWrapper.clearAll()
        APIManager.shared.primeAPI = self.mockAPI
        self.setupStubbing()
    }
    
    override func tearDown() {
        self.tearDownStubbing()
        APIManager.shared.primeAPI = PrimeAPI(baseURL: APIManager.shared.baseURLString, tokenProvider: UserManager.shared)
        UserDefaultsWrapper.clearAll()
        super.tearDown()
    }
    
    func testNoLoggedInUserKicksToLogin() {
        self.testUserManager.mockHasCurrentUser = false
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .login)
    }
    
    func testPendingEmailConfirmationKicksToEmail() {
        self.testUserManager.mockHasCurrentUser = true
        UserDefaultsWrapper.pendingEmail = "fake@fake.com"
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .email)
    }
    
    func testCustomerWithNoContextIsKickedToSignUp() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "customer_nonexistent", statusCode: 404)
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .signUp)
    }
    
    func testCustomerWithNoRegionsIsKickedToCountry() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_no_regions")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .country)
    }
    
    func testCustomerWithRegionAndPendingStatusIsKickedToEKYC() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_singapore_all_pending")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        switch destination {
        case .ekyc(let region):
            guard let region = region else {
                XCTFail("Region should not be nil here!")
                return
            }
            
            XCTAssertEqual(region.region.id, "sg")
        default:
            XCTFail("Incorrect destination!, expected ekyc, got \(destination)")
        }
    }
    
    func testCustomerWithRegionAndRejectedStatusIsKickedToEKYC() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_jumio_rejected")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        switch destination {
        case .ekyc(let region):
            guard let region = region else {
                XCTFail("Region should not be nil here!")
                return
            }
            
            XCTAssertEqual(region.region.id, "sg")
        default:
            XCTFail("Incorrect destination!, expected ekyc, got \(destination)")
        }
    }
    
    func testCustomerWithRegionAndApprovedStatusButWithoutEsimIsKickedToEsim() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_jumio_approved")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        switch destination {
        case .esim(let profile):
            // We should not have a profile yet
            XCTAssertNil(profile)
        default:
            XCTFail("Incorrect destination - expecting esim, got \(destination)")
        }
    }
    
    func testCustomerWithPendingEsimDownloadIsKickedToEsim() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_with_pending_sim_profile")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        switch destination {
        case .esim(let profile):
            guard let profile = profile else {
                XCTFail("There should be a profile here!")
                return
            }
            
            XCTAssertEqual(profile.status, .AVAILABLE_FOR_DOWNLOAD)
        default:
            XCTFail("Unexpected destination, expected esim, got \(destination)")
        }
    }
    
    func testCustomerWithDownloadedEsimIsKickedToHome() {
        self.testUserManager.mockHasCurrentUser = true
        self.stubPath("context", toLoad: "context_with_downloaded_sim_profile")
        
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .home)
    }
}
