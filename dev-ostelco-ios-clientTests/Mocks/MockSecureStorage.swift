//
//  MockSecureStorage.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import ostelco_core

/// Mock class to allow easier testing of things which would otherwise require legit keychain access
class MockSecureStorage: SecureStorage {
    
    private var fakeKeychain = [KeychainKey: String]()
    
    func setString(_ string: String, for key: KeychainKey) {
        self.fakeKeychain[key] = string
    }
    
    func getString(for key: KeychainKey) -> String? {
        return self.fakeKeychain[key]
    }
    
    func clearValue(for key: KeychainKey) {
        self.fakeKeychain.removeValue(forKey: key)
    }
    
    func clearSecureStorage() {
        self.fakeKeychain = [KeychainKey: String]()
    }
}
