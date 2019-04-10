//
//  KeychainWrapper.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import KeychainAccess

// Keys to use for storing and retrieving objects from the keychain
public enum KeychainKey: String, CaseIterable {
    case Auth0
}

/// Protocol representing things which should be stored securely
public protocol SecureStorage {
    
    /// Sets the given string for the given key in secure storage.
    ///
    /// - Parameters:
    ///   - string: The string to store.
    ///   - key: The key to use to store the string.
    func setString(_ string: String, for key: KeychainKey)
    
    /// Attempts to get a string for the given key from secure storage
    ///
    /// - Parameter key: The key to retrieve a string from out of secure storage.
    /// - Returns: The stored value, or nil if no stored value was found or an error occurred
    func getString(for key: KeychainKey) -> String?
    
    /// Clears the value for a given key from secure storage
    ///
    /// - Parameter key: The key to clear the value for
    func clearValue(for key: KeychainKey)
    
    /// Clears the value for all `KeychainKey`s from secure storage. Useful for testing and user logout.
    func clearSecureStorage()
}

/// A concrete wrapper around the iOS Keychain implementing SecureStorage.
public class KeychainWrapper: SecureStorage {

    // TODO: Get access group set up on the dev center
    private let accessGroup: String = "CREATE ACCESS GROUP"
    private let service: String = "ostelco"
    
    private lazy var keychain: Keychain = {
       return Keychain(service: self.service, accessGroup: self.accessGroup)
            .accessibility(.afterFirstUnlock)
    }()
    
    // MARK: - SecureStorage
    
    public func setString(_ string: String, for key: KeychainKey) {
        self.keychain[key.rawValue] = string
    }
    
    public func getString(for key: KeychainKey) -> String? {
        return self.keychain[key.rawValue]
    }
    
    public func clearValue(for key: KeychainKey) {
        do {
            try self.keychain.remove(key.rawValue)
        } catch {
            debugPrint("- [KEYCHAIN WRAPPER]: Error removing value for key \(key.rawValue): \(error)")
        }
    }
    
    public func clearSecureStorage() {
        KeychainKey.allCases.forEach { key in
            self.clearValue(for: key)
        }
    }
}

