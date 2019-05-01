//
//  HeaderGeneratorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import XCTest

class HeaderGeneratorTests: XCTestCase {
    
    func testGeneratingHeadersWithEmptyKeychainSucceedsForNonLoggedIn() {
        do {
            let headers = try Headers(loggedIn: false, secureStorage: MockSecureStorage())
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 1)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
        } catch {
            XCTFail("Headers should not have thrown!")
        }
    }
    
    func testGeneratingHeadersWithEmptyKeychainFailsForLoggedIn() {
        do {
            _ = try Headers(loggedIn: true, secureStorage: MockSecureStorage())
            XCTFail("There should be an error thrown when trying to get logged in headers with no token")
        } catch {
            switch error {
            case Headers.Error.noTokenForLoggedInRequest:
                // This is what we want!
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testGeneratingHeadersWithNonEmptyKeychainSuccedsForNotLoggedIn() {
        let storage = MockSecureStorage()
        storage.setString("test!", for: .Auth0Token)
        
        do {
            let headers = try Headers(loggedIn: false, secureStorage: storage)
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 1)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
    
    func testGeneratingHeadersWithNonEmptyKeychainSucceedsForLoggedIn() {
        let storage = MockSecureStorage()
        let testToken = "I'M A TEST TOKEN!"
        storage.setString(testToken, for: .Auth0Token)
        
        do {
            let headers = try Headers(loggedIn: true, secureStorage: storage)
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 2)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
            XCTAssertEqual(headerDict[HeaderKey.authorization.rawValue], testToken)

        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
}
