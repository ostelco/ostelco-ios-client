//
//  PushNotificationController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import FirebaseMessaging
import Foundation
import ostelco_core
import PromiseKit
import UserNotifications
import UIKit

/// A controller for handling push notifications.
open class PushNotificationController: NSObject {
    
    enum Error: Swift.Error {
        case notAuthorized(status: UNAuthorizationStatus)
    }
    
    /// Singleton instance.
    static let shared = PushNotificationController()
    
    /// The user manager to use when trying to figure out if anyone is logged in. Variable for testing.
    var userManager = UserManager.shared
    
    override init() {
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Allow direct delivery bypassing APNS when the app is open.
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    /// Checks for the user's notification settings
    ///
    /// - Returns: A Promise which when fulfilled will have the user's notification settings
    open func getNotificationSettings() -> Promise<UNNotificationSettings> {
        return Promise { seal in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                seal.fulfill(settings)
            }
        }
    }
    
    /// Registers the user for remote notifications.
    open func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    /// Requests authorization for remote notifications.
    ///
    /// - Returns: A Promise which when fulfilled will include a Boolean indicating whether the request was granted or not.
    open func requestAuthorization() -> Promise<Bool> {
        return Promise { seal in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    seal.reject(error)
                } else {
                    if granted {
                        OstelcoAnalytics.logEvent(.PushNotificationsAccepted)
                    } else {
                        OstelcoAnalytics.logEvent(.PushNotificationsDeclined)
                    }
                    
                    seal.fulfill(granted)
                }
            }
        }
    }

    /// Determines if a user has authorized push notifications, and if they have, registers them for remote
    /// notifications.
    ///
    /// - Parameter authorizeIfNotDetermined: If the user's authorization status has not been determined, should we
    ///                                       prompt them to authorize? Pass true to show authorization immediately.
    /// - Returns: A promise which, when fulfilled, indicates whether the user is now registered for notifications.
    ///            Note that statuses other than `.notDetermined` and `.authorized` will cause the Promise to reject.
    open func checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: Bool) -> Promise<Bool> {
        return self.getNotificationSettings()
            .then { settings -> Promise<Bool> in
                switch settings.authorizationStatus {
                case .notDetermined:
                    if authorizeIfNotDetermined {
                        return self.requestAuthorization()
                    } else {
                        // Don't try to authorize, but also don't error. Just return false.
                        return .value(false)
                    }
                case .authorized:
                    return .value(true)
                default:
                    throw Error.notAuthorized(status: settings.authorizationStatus)
                }
            }
            .map { authorized in
                if authorized {
                    self.registerForRemoteNotifications()
                }
                
                return authorized
            }
    }
    
    func sendFCMToken(_ fcmToken: String?) {
        guard
            self.userManager.firebaseUser != nil,
            let token = fcmToken else {
                // Wait to be authenticated, or the token to be ready.
                return
        }
        
        // Use the application ID as <BundleId>.<Unique DeviceID or UUID>
        let appId = "\(Bundle.main.bundleIdentifier!).\(UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString)"
        
        let pushToken = PushToken(token: token, applicationID: appId)
        APIManager.shared.primeAPI.sendPushToken(pushToken)
            .done {
                debugPrint("Set new FCM token: \(token)")
            }
            .catch { error in
                ApplicationErrors.log(error)
        }
    }
    
    // MARK: - App Delegate Matching methods
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
         Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
        ApplicationErrors.log(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         Messaging.messaging().apnsToken = deviceToken
    }
}

extension PushNotificationController: UNUserNotificationCenterDelegate {
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        self.sendDidReceivePushNotification(userInfo)
        completionHandler([])
    }
    
    open func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     didReceive response: UNNotificationResponse,
                                     withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.sendDidReceivePushNotification(userInfo)
        completionHandler()
    }
    
    open func sendDidReceivePushNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .didReceivePushNotification, object: self, userInfo: userInfo)
    }
}

extension PushNotificationController: MessagingDelegate {
    
    open func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        debugPrint("- PushNotificationController: Firebase registration token: \(fcmToken)")
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        self.sendFCMToken(fcmToken)
    }

    open func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        debugPrint("- PushNotificationController: Received data message: \(remoteMessage.appData)")
    }
}

extension Notification.Name {
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}
