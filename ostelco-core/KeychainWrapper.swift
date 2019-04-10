//
//  KeychainWrapper.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import SimpleKeychain

public enum KeychainKey: String, CaseIterable {
    case Auth0
}

public protocol SecureStorage {
    func setString(_ string: String, for key: KeychainKey)
    func getString(for key: KeychainKey) -> String?
    func clearValue(for key: KeychainKey)
    
    func clearSecureStorage()
}

public class KeychainWrapper: SecureStorage {
    
    private let accessGroup: String = "CREATE ACCESS GROUP"
    private let service: String = "Auth0"
    
    private lazy var keychain: A0SimpleKeychain = {
       return A0SimpleKeychain(service: self.service, accessGroup: self.accessGroup)
    }()
    
    // MARK: - SecureStorage
    
    public func setString(_ string: String, for key: KeychainKey) {
        self.keychain.setString(string, forKey: key.rawValue)
    }
    
    public func getString(for key: KeychainKey) -> String? {
        return self.keychain.string(forKey: key.rawValue)
    }
    
    public func clearValue(for key: KeychainKey) {
        self.keychain.deleteEntry(forKey: key.rawValue)
    }
    
    public func clearSecureStorage() {
        KeychainKey.allCases.forEach { key in
            self.clearValue(for: key)
        }
    }
}

