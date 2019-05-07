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
    
    func testGeneratingHeadersWithNilTokenSucceedsForNonLoggedIn() {
        do {
            let headers = try Headers(loggedIn: false, token: nil)
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 1)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
        } catch {
            XCTFail("Headers should not have thrown!")
        }
    }
    
    func testGeneratingHeadersWithNilTokenFailsForLoggedIn() {
        do {
            _ = try Headers(loggedIn: true, token: nil)
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
    
    func testGeneratingHeadersWithNonNilTokenSuccedsForNotLoggedIn() {
        do {
            let headers = try Headers(loggedIn: false, token: "test!")
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 1)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
    
    func testGeneratingHeadersWithNonNilTokenSucceedsForLoggedIn() {
        let testToken = "I'M A TEST TOKEN!"
        
        do {
            let headers = try Headers(loggedIn: true, token: testToken)
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 2)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
            XCTAssertEqual(headerDict[HeaderKey.authorization.rawValue], "Bearer \(testToken)")
        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
    
    func testAddingAnAdditionalHeader() {
        let testToken = "I'M A TEST TOKEN!"
        
        do {
            var headers = try Headers(loggedIn: true, token: testToken)
            headers.addValue(.testing("TEST"), for: .testing)
            
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 3)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
            XCTAssertEqual(headerDict[HeaderKey.authorization.rawValue], "Bearer \(testToken)")
            XCTAssertEqual(headerDict[HeaderKey.testing.rawValue], "TEST")
        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
    
    func testReplacingADefaultHeader() {
        let testToken = "I'M A TEST TOKEN!"
        
        do {
            var headers = try Headers(loggedIn: true, token: testToken)
            headers.addValue(.testing("TEST"), for: .contentType)
            let headerDict = headers.toStringDict
            XCTAssertEqual(headerDict.count, 2)
            XCTAssertEqual(headerDict[HeaderKey.contentType.rawValue], "TEST")
            XCTAssertEqual(headerDict[HeaderKey.authorization.rawValue], "Bearer \(testToken)")
        } catch {
            XCTFail("Unexpected error creating headers: \(error)")
        }
    }
}
