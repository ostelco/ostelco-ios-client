//
//  KeychainWrapper.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import KeychainAccess

/// A concrete wrapper around the iOS Keychain implementing SecureStorage.
public class KeychainWrapper: SecureStorage {
    
    private let service = "ostelco"
    private let accessGroupPrefix = "2R8HFAXUXD" // App identifer
    private let accessGroup: String
    
    /// Designated initializer
    ///
    /// - Parameter accessGroup: The access group for the current application.
    public init(appBundleID: String) {
        self.accessGroup = self.accessGroupPrefix + appBundleID
    }
    
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
