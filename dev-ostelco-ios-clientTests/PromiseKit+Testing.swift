//
//  PromiseKit+Testing.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import XCTest

extension Promise {
    
    func awaitResult(in testCase: XCTestCase,
                     timeout: TimeInterval = 10,
                     file: StaticString = #file,
                     line: UInt = #line) -> T? {
        let expectation = testCase.expectation(description: "Awaiting fulfillment of promise")
        
        var result: T?
        self
            .done { item in
                result = item
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Error awaiting result: \(error)",
                        file: file,
                        line: line)
                
                expectation.fulfill()
            }
        
        testCase.wait(for: [expectation], timeout: timeout)
        return result
    }
    
    func awaitResultExpectingError(in testCase: XCTestCase,
                                   timeout: TimeInterval = 10,
                                   file: StaticString = #file,
                                   line: UInt = #line) -> Error? {
        
        let expectation = testCase.expectation(description: "Awaiting rejection of promise")
        
        var error: Error?
        self
            .done { _ in
                XCTFail("Request succeeded when it shouldn't have!",
                        file: file,
                        line: line)
                expectation.fulfill()
            }
            .catch { promiseError in
                error = promiseError
                expectation.fulfill()
            }
        
        testCase.wait(for: [expectation], timeout: timeout)
        return error
    }
    
}
