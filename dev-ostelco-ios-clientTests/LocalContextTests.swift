//
//  LocalContextTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Samuel Goodwin on 8/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class LocalContextTests: XCTestCase {
    
    func testOneTimeAccessToMyInfoCode() {
        
        let context = LocalContext(myInfoCode: "xxxx")
        
        XCTAssertNotNil(context.myInfoCode)
        XCTAssertNil(context.myInfoCode)
    }
    
    func testOneTimeAccessToMyInfoCodeInsideAFunction() {
        
        let context = LocalContext(myInfoCode: "xxxx")
        
        func process(_ a: LocalContext) -> Bool {
            if a.myInfoCode != nil {
                return true
            }
            return false
        }
        
        XCTAssert(process(context))
        XCTAssertNil(context.myInfoCode)
    }
}
