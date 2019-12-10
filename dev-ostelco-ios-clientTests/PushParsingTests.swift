//
//  PushParsingTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/20/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class PushParsingTests: XCTestCase {
    
    class PushHandler: PushNotificationHandling {
        var pushNotificationObserver: NSObjectProtocol?
        var notification: PushNotificationContainer?
        
        func handlePushNotification(_ notification: PushNotificationContainer) {
            self.notification = notification
        }
    }
    
    private lazy var testPushHandler = PushHandler()
    
    private func loadMockPushJSON(named name: String = "push_notification",
                                  file: StaticString = #file,
                                  line: UInt = #line) -> [AnyHashable: Any]? {
        guard
            let file = Bundle(for: PushParsingTests.self).url(forResource: name, withExtension: "json", subdirectory: "MockJSON"),
            let data = try? Data(contentsOf: file),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
                XCTFail("Couldn't load test json!")
                return nil
        }
        
        return dict
    }
    
    // MARK: - Tests
    
    func testConvertingUserInfoDictToContainerObject() {
        guard let dict = self.loadMockPushJSON() else {
            // Failures handled in loader
            return
        }
        
        guard let container = PushNotificationContainer(dictionary: dict) else {
            XCTFail("Couldn't convert dictionary to container!")
            return
        }
        
        XCTAssertEqual(container.gcmMessageID, "0:fake_message_id%gibberish")
        
        guard let alert = container.alert else {
            XCTFail("Couldn't get alert!")
            return
        }
        
        XCTAssertEqual(alert.notification.title, "Test notification")
        XCTAssertEqual(alert.notification.body, "I am a test!")
        
        // TODO: Update with real data
        XCTAssertNil(alert.notification.data)
    }
    
    func testConvertingUserInfoDictToNotificationObject() {
        guard let dict = self.loadMockPushJSON() else {
            // Failures handled in loader
            return
        }
        
        guard let notification = self.testPushHandler.convertToNotificationContainer(userInfo: dict) else {
            XCTFail("Couldn't create notification!")
            return
        }
        
        XCTAssertEqual(notification.alert?.notification.title, "Test notification")
        XCTAssertEqual(notification.alert?.notification.body, "I am a test!")
        
        // TODO: Update with real data
        XCTAssertNil(notification.alert?.notification.data)
    }
    
    func testConvertingPushNotificationWithScanInfo() {
        guard let dict = self.loadMockPushJSON(named: "push_notification_scan_success") else {
            // Failures handled in loader
            return
        }
        
        guard let notification = self.testPushHandler.convertToNotificationContainer(userInfo: dict) else {
            XCTFail("Couldn't create notification!")
            return
        }
        
        XCTAssertEqual(notification.gcmMessageID, "1:fake_message_id%gibberish")
        
        guard let scan = notification.scanInfo else {
            XCTFail("Couldn't get scan info!")
            return
        }
        
        XCTAssertEqual(scan.countryCode, "sg")
        XCTAssertEqual(scan.scanId, "fake_scan_id")
        XCTAssertEqual(scan.status, .APPROVED)
        
        guard let result = scan.scanResult else {
            XCTFail("Couldn't get result info!")
            return
        }
        
        XCTAssertEqual(result.verificationStatus, .APPROVED_VERIFIED)
        XCTAssertEqual(result.vendorScanReference, "vendor_fake_scan_id")
        XCTAssertNil(result.rejectReason)
    }
}
