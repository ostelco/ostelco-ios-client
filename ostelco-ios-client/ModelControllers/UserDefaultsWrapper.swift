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
        case selectedTheme = "SelectedTheme"
        case userLoggedOutKey = "UserLoggedOut"
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
    
    /// What, if any, is the stored theme for this user? 
    static var storedTheme: Theme? {
        get {
            guard
                let themeValue: Int = self.value(for: .selectedTheme),
                let theme = Theme(rawValue: themeValue) else {
                    return nil
            }
            
            return theme
        }
        set {
            if let themeToStore = newValue {
                self.setValue(themeToStore.rawValue, for: .selectedTheme)
            } else {
                self.removeValue(for: .selectedTheme)
            }
        }
    }
    
    static var userLoggedOut: Bool {
        set {
            self.setValue(newValue, for: .userLoggedOutKey)
        }
        get {
            guard let value: Bool = self.value(for: .userLoggedOutKey) else {
                return false
            }
            
            return value
        }
    }
}
