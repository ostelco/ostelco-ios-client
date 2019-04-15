//
//  KeychainTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 4/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import ostelco_core
import XCTest

class KeychainTests: XCTestCase {
    
    private lazy var keychainWrapper = KeychainWrapper()
    
    override func setUp() {
        super.setUp()
        self.keychainWrapper.clearSecureStorage()
    }
    
    override func tearDown() {
        self.keychainWrapper.clearSecureStorage()
        super.tearDown()
    }
    
    func testStoringAndRetrievingValueInKeychain() {
        let value = "Hello tests!"
        self.keychainWrapper.setString(value, for: .Auth0)
        
        guard let retrievedValue = self.keychainWrapper.getString(for: .Auth0) else {
            XCTFail("Coudldn't retrieve value from the keychain!")
            return
        }
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testClearingSecureStorage() {
        // Add values for all keys
        KeychainKey.allCases.forEach { self.keychainWrapper.setString("A value!", for: $0) }
        
        // Make sure the values are all non nil before clearing
        KeychainKey.allCases.forEach {
            XCTAssertNotNil(self.keychainWrapper.getString(for: $0),
                            "Value for \($0.rawValue) was unexpectedly nil!")
        }
        
        self.keychainWrapper.clearSecureStorage()
        
        // Now make sure all values are gone
        KeychainKey.allCases.forEach {
            XCTAssertNil(self.keychainWrapper.getString(for: $0),
                         "Value for \($0.rawValue) should have been nil but wasn't!")
        }
    }
}
