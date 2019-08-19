//
//  UserDefaultsWrapper.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct UserDefaultsWrapper {
    
    // Underlying keys for user defaults
    private enum Key: String, CaseIterable {
        case pendingSingPassQueryItems = "PendingSingPassQueryItems"
        case contactEmail = "ContactEmail"
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
    public static func clearAll() {
        for key in Key.allCases {
            self.removeValue(for: key)
        }
    }
    
    public static var pendingSingPass: [URLQueryItem]? {
        get {
            guard let dict: [String: String?] = self.value(for: .pendingSingPassQueryItems) else {
                return nil
            }
            
            let queryItems = dict.map { key, value in
                return URLQueryItem(name: key, value: value)
            }
            
            return queryItems
        }
        set {
            if let newQueryItems = newValue {
                var dict = [String: String?]()
                for item in newQueryItems {
                    dict[item.name] = item.value
                }
                
                self.setValue(dict, for: .pendingSingPassQueryItems)
            } else {
                self.removeValue(for: .pendingSingPassQueryItems)
            }
        }
    }

    /// The contact Email to be used while creating the user.
    public static var contactEmail: String? {
        get {
            return self.value(for: .contactEmail)
        }
        set {
            if let newEmail = newValue {
                self.setValue(newEmail, for: .contactEmail)
            } else {
                self.removeValue(for: .contactEmail)
            }
        }
    }

}
