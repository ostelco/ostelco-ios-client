//
//  PushNotificationControllerTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class PushNotificationControllerTests: XCTestCase {
    
    private lazy var testUserManager = MockUserManager()

    private lazy var testController: MockPushNotificationController = {
        let controller = MockPushNotificationController()
        controller.userManager = self.testUserManager
        controller.primeAPI = self.mockAPI
        
        return controller
    }()
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        self.setupStubbing()
    }
    
    override func tearDown() {
        self.tearDownStubbing()
        super.tearDown()
    }
    
    private func setupTokenMock() {
        self.stubPath("applicationToken", toLoad: "send_push_token")
    }
    
    // MARK: - Tests
    
    func testRegisteringForPushNotificationsNotForcingAuthorizationAndAccepting() {
        let fcmToken = "No forced auth and accepted"
        self.testController.fakeFCMToken = fcmToken
        self.setupTokenMock()
        
        guard let authorized = self.testController
            .checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: false)
            .awaitResult(in: self) else {
                // Failures handled in `awaitResult`.
                return
        }
        
        XCTAssertFalse(authorized)
        XCTAssertNil(self.testController.sentFCMToken)
    }
    
    func testRegisteringForPushNotificationsForcingAuthorizationAndAccepting() {
        let fcmToken = "Forced auth and accepted"
        self.testController.fakeFCMToken = fcmToken
        self.setupTokenMock()

        guard let authorized = self.testController
            .checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .awaitResult(in: self) else {
                // Failures handled in `awaitResult`.
                return
        }
        
        XCTAssertTrue(authorized)
        
        guard let promise = self.testController.activeSendTokenPromise else {
            XCTAssertEqual(self.testController.sentFCMToken, fcmToken)
            return
        }
        
        promise.awaitResult(in: self)
        self.testController.activeSendTokenPromise = nil

        XCTAssertEqual(self.testController.sentFCMToken, fcmToken)
    }
    
    func testRegisteringForPushNotificationsForcingAuthorizationAndDeclining() {
        let fcmToken = "Forced auth and declined"
        self.testController.fakeFCMToken = fcmToken
        self.testController.authorizationStatus = .denied

        guard let error = self.testController
            .checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .awaitResultExpectingError(in: self) else {
                // Unexpected success handled in `awaitResult`.
                return
        }
        
        XCTAssertNil(self.testController.sentFCMToken)
        
        switch error {
        case PushNotificationController.Error.notAuthorized(let status):
            XCTAssertEqual(status, .denied)
        default:
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRegisteringForPushNotificationsAlreadyAuthorized() {
        let fcmToken = "Already authorized"
        self.testController.fakeFCMToken = fcmToken
        self.testController.authorizationStatus = .authorized
        self.setupTokenMock()

        guard let authorized = self.testController
            .checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: false)
            .awaitResult(in: self) else {
                // Failures handled in `awaitResult`
                return
        }
        
        XCTAssertTrue(authorized)
        
        guard let promise = self.testController.activeSendTokenPromise else {
            XCTAssertEqual(self.testController.sentFCMToken, fcmToken)
            return
        }
        
        promise.awaitResult(in: self)
        self.testController.activeSendTokenPromise = nil
        
        XCTAssertEqual(self.testController.sentFCMToken, fcmToken)
    }
    
    func testReceivingAPushNotificationSendsLocalNotification() {
        let testName = String(staticString: #function)
        let testDict = [ "test": testName ]
        
        let notificationExpectation = self.expectation(
            forNotification: .didReceivePushNotification,
            object: self.testController,
            handler: { notification -> Bool in
                guard let value = notification.userInfo?["test"] as? String else {
                    return false
                }
                
                return value == testName
            })
        
        self.testController.application(UIApplication.shared, didReceiveRemoteNotification: testDict)
        self.wait(for: [notificationExpectation], timeout: 2)
        
        guard let userInfo = self.testController.receivedRemoteAppleUserInfo else {
            XCTFail("User info didn't come through!")
            return
        }
        
        XCTAssertEqual(userInfo["test"] as? String, testName)
    }
    
    func testReceivingABackgroundPushNotificationSendsLocalNotificaiton() {
        let testName = String(staticString: #function)
        let testDict = [ "test": testName ]
        
        let notificationExpectation = self.expectation(
            forNotification: .didReceivePushNotification,
            object: self.testController,
            handler: { notification -> Bool in
                guard let value = notification.userInfo?["test"] as? String else {
                    return false
                }
                
                return value == testName
        })
        
        var result: UIBackgroundFetchResult?
        self.testController.application(UIApplication.shared,
                                        didReceiveRemoteNotification: testDict,
                                        fetchCompletionHandler: { handlerResult in
                                            result = handlerResult
                                        })
        self.wait(for: [notificationExpectation], timeout: 2)
        
        guard let userInfo = self.testController.receivedRemoteAppleUserInfo else {
            XCTFail("User info didn't come through!")
            return
        }
        
        XCTAssertEqual(userInfo["test"] as? String, testName)
        XCTAssertEqual(result, .newData)
    }
}
