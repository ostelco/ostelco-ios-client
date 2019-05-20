//
//  PushNotificationHandling.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

/// A protocol to allow any class to listen to push notifications
protocol PushNotificationHandling: class {
    
    /// The NSNotificationCenter observer which is listening for push notifications
    var pushNotificationObserver: NSObjectProtocol? { get set }
    
    /// Called when a push notification NSNotification is recevied.
    ///
    /// - Parameter userInfo: The user info from the NSNotificaiton (which should in turn be from the push notification)
    func handlePushNotification(userInfo: [AnyHashable: Any]?)
}

// MARK: - Default implementation

extension PushNotificationHandling {
    
    func addPushNotificationListener() {
        self.pushNotificationObserver = NotificationCenter.default.addObserver(
            forName: .didReceivePushNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                self?.handlePushNotification(userInfo: notification.userInfo)
            })
    }
    
    func removePushNotificationListener() {
        guard let removeMe = self.pushNotificationObserver else {
            // Nothing to remove
            return
        }
        
        NotificationCenter.default.removeObserver(removeMe)
        self.pushNotificationObserver = nil
    }
}
