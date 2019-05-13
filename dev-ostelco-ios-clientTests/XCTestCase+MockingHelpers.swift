//
//  XCTestCase+MockingHelpers.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/13/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OHHTTPStubs
import ostelco_core
import XCTest

extension XCTestCase {
    
    var baseURL: URL {
        return URL(string: "https://api.fake.org")!
    }

    var mockAPI: PrimeAPI {
        return PrimeAPI(baseURL: self.baseURL.absoluteString, tokenProvider: self.mockTokenProvider)
    }
    
    func setupStubbing() {
        OHHTTPStubs.setEnabled(true)
    }
    
    func tearDownStubbing() {
        OHHTTPStubs.removeAllStubs()
        OHHTTPStubs.setEnabled(false)
    }
    
    private var mockTokenProvider: MockTokenProvider {
        let provider = MockTokenProvider()
        provider.initialToken = "Initial Test Token"
        return provider
    }
    
    func stubPath(_ path: String,
                  toLoad fileName: String,
                  statusCode: Int32 = 200,
                  file: StaticString = #file,
                  line: UInt = #line) {
        OHHTTPStubs.stubRequests(passingTest: isPath("/\(path)"),
                                 withStubResponse: self.loadFile(named: fileName,
                                                                 statusCode: statusCode,
                                                                 file: file,
                                                                 line: line))
    }
    
    func stubAbsoluteURLString(_ absoluteURLString: String,
                               toLoad fileName: String,
                               statusCode: Int32 = 200,
                               file: StaticString = #file,
                               line: UInt = #line) {
        OHHTTPStubs.stubRequests(passingTest: isAbsoluteURLString(absoluteURLString),
                                 withStubResponse: self.loadFile(named: fileName,
                                                                 statusCode: statusCode,
                                                                 file: file,
                                                                 line: line))
    }
    
    private func loadFile(named fileName: String,
                          statusCode: Int32,
                          file: StaticString = #file,
                          line: UInt = #line) -> OHHTTPStubsResponseBlock {
        return { _ in
            guard let path = Bundle(for: MockAPITests.self).path(forResource: fileName, ofType: "json", inDirectory: "MockJSON") else {
                XCTFail("Couldn't get bundled path!",
                        file: file,
                        line: line)
                return OHHTTPStubsResponse(error: NSError(domain: "", code: 0, userInfo: nil))
            }
            
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: statusCode, headers: nil)
        }
    }
    
    func stubEmptyDataAtPath(_ path: String,
                             statusCode: Int32) {
        OHHTTPStubs.stubRequests(passingTest: isPath("/\(path)")) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: statusCode, headers: nil)
        }
    }
}
