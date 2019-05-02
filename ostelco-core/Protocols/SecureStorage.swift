//
//  SecureStorage.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

// Keys to use for storing and retrieving objects from the keychain
public enum KeychainKey: String, CaseIterable {
    case Auth0Token
    case Auth0RefreshToken
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
