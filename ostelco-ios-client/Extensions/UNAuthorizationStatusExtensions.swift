//
//  UNAuthorizationStatusExtensions.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UserNotifications

extension UNAuthorizationStatus {
    var description: String {
        get {
            switch (self) {
            case .notDetermined:
                return "not determined"
            case .denied:
                return "denied"
            case .authorized:
                return "authorized"
            case .provisional:
                return "provisional"
            @unknown default:
                assertionFailure("Apple added something! You should handle it here.")
                return ""
            }
        }
    }
}
