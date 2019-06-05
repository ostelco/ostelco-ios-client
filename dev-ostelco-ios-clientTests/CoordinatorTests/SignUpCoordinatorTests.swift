//
//  SignUpCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class SignUpCoordinatorTests: XCTestCase {
    
    private lazy var testUserManager = MockUserManager()
    
    private lazy var testNotificationController = MockPushNotificationController()
    
    private lazy var testCustomer = CustomerModel(id: "test",
                                                  name: "Testy",
                                                  email: "testy@mctesters.on",
                                                  analyticsId: "test",
                                                  referralId: "test")
    
    private lazy var testCoordinator = SignUpCoordinator(navigationController: UINavigationController(),
                                                         userManager: self.testUserManager,
                                                         notificationController: self.testNotificationController)
    
    func testLegaleseNotAgreedKicksToLegalese() {
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: false).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .legalese)
    }
    
    func testLegaleseAgreedButNoCustomerKicksToEnterName() {
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .enterName)
    }
    
    func testLegaleseAgreedWithCustomerAndPushNotYetAskedKicksToPush() {
        self.testUserManager.customer = self.testCustomer
        self.testNotificationController.authorizationStatus = .notDetermined
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .allowPushNotifications)
    }
    
    func testLegaleseAgreedWithCustomerAndProvisionalPushKicksToPush() {
        self.testUserManager.customer = self.testCustomer
        self.testNotificationController.authorizationStatus = .provisional
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .allowPushNotifications)
    }
    
    func testLegaleseAgreedWithCustomerAndPushDeniedKicksToCompleted() {
        self.testUserManager.customer = self.testCustomer
        self.testNotificationController.authorizationStatus = .denied
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .signupComplete)
    }
    
    func testLegaleseAgreedWithCustomerAndPushAuthorizedKicksToCompleted() {
        self.testUserManager.customer = self.testCustomer
        self.testNotificationController.authorizationStatus = .authorized
        guard let destination = self.testCoordinator.determineDestination(isLegaleseAgreed: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .signupComplete)
    }
}
