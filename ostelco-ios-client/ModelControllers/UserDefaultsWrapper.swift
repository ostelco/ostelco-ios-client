//
//  UserDefaultsWrapper.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct UserDefaultsWrapper {
    
    // Underlying keys for user defaults
    private enum Key: String, CaseIterable {
        case pendingEmail = "PendingEmail"
    }
    
    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private static func removeValue(for key: Key) {
        self.defaults.removeObject(forKey: key.rawValue)
    }
    
    private static func setValue<T>(_ value: T, for key: Key) {
        self.defaults.setValue(value, forKey: key.rawValue)
    }
    
    private static func value<T>(for key: Key) -> T? {
        return self.defaults.value(forKey: key.rawValue) as? T
    }
    
    /// Remove every default stored through this wrapper
    static func clearAll() {
        for key in Key.allCases {
            self.removeValue(for: key)
        }
    }
    
    /// What is the email we are waiting to confirm?
    static var pendingEmail: String? {
        get {
            return self.value(for: .pendingEmail)
        }
        set {
            if let newEmail = newValue {
                self.setValue(newEmail, for: .pendingEmail)
            } else {
                self.removeValue(for: .pendingEmail)
            }
        }
    }
}
