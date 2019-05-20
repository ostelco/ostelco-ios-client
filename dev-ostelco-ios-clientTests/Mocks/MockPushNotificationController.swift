//
//  MockPushNotificationController.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import FirebaseMessaging
@testable import Oya_Development_app
import PromiseKit
import UIKit
import UserNotifications

class MockPushNotificationController: PushNotificationController {
    
    enum Error: Swift.Error {
        case fakeFCMTokenNotSet
    }
    
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var shouldAuthorize: Bool = true
    
    var fakeFCMToken: String?
    
    private(set) var receivedRemoteAppleUserInfo: [AnyHashable: Any]?
    private(set) var sentFCMToken: String?

    override func getAuthorizationStatus() -> Promise<UNAuthorizationStatus> {
        return .value(self.authorizationStatus)
    }
    
    override func registerForRemoteNotifications() {
        if let token = self.fakeFCMToken {
            self.messaging(Messaging.messaging(), didReceiveRegistrationToken: token)
        } else {
            self.application(UIApplication.shared,
                             didFailToRegisterForRemoteNotificationsWithError: Error.fakeFCMTokenNotSet)
        }
    }

    override func requestAuthorization() -> Promise<Bool> {
        return .value(self.shouldAuthorize)
    }

    override func sendFCMToken(_ fcmToken: String?) -> Promise<Void> {
        self.sentFCMToken = fcmToken
        return super.sendFCMToken(fcmToken)
    }
    
    override func otherAppleUserInfoHandling(_ userInfo: [AnyHashable: Any]) {
        self.receivedRemoteAppleUserInfo = userInfo
    }
}
