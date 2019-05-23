//
//  PushNotificationHandling.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

/// A protocol to allow any class to listen to push notifications
protocol PushNotificationHandling: class {
    
    /// The NSNotificationCenter observer which is listening for push notifications
    var pushNotificationObserver: NSObjectProtocol? { get set }
    
    /// Called when a push notification NSNotification is recevied.
    ///
    /// - Parameter userInfo: The parsed notification from the NSNotification.
    func handlePushNotification(_ notification: PushNotification)
}

// MARK: - Default implementation

extension PushNotificationHandling {
    
    func addPushNotificationListener() {
        self.pushNotificationObserver = NotificationCenter.default.addObserver(
            forName: .didReceivePushNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let self = self else {
                    // Don't bother trying to process.
                    return
                }
                
                guard
                    let pushObject = self.convertToNotification(userInfo: notification.userInfo) else {
                    let error = ApplicationErrors.General.couldntConvertUserInfoToNotificaitonData(userInfo: notification.userInfo)
                    ApplicationErrors.assertAndLog(error)
                        return
                }
                
                self.handlePushNotification(pushObject)
            })
    }
    
    /// Attempts to convert a user info dictionary passed through an NSNotification to a `PushNotification` object.
    ///
    /// - Parameter dictionary: The user info dictionary to parse, or nil
    /// - Returns: The parsed push notification, or nil if one could not be parsed.
    func convertToNotification(userInfo dictionary: [AnyHashable: Any]?) -> PushNotification? {
        guard
            let dictionary = dictionary,
            let container = PushNotificationContainer(dictionary: dictionary) else {
                return nil
        }
        
        return container.alert?.notification
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
