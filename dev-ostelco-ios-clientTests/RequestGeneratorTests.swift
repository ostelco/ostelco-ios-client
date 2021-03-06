//
//  RequestGeneratorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import XCTest
@testable import Oya_Development_app

class RequestGeneratorTests: XCTestCase {
    
    private lazy var testURL: URL = {
        guard let url = URL(string: "https://www.test.nl/api") else {
            fatalError("This should create a URL!")
        }
        
        return url
    }()
    
    private lazy var testToken = "Testing!"
    
    func testBasicInitializationGivesAGetRequest() throws {
        let request = Request(baseURL: self.testURL,
                              path: "test",
                              loggedIn: false,
                              token: self.testToken)
        
        let urlRequest = try request.toURLRequest()
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.test.nl/api/test")
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.GET.rawValue)
        XCTAssertNil(urlRequest.httpBody)
        guard let headers = urlRequest.allHTTPHeaderFields else {
            XCTFail("Could not access headers!")
            return
        }
        
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
    }
    
    func testAddingPutDataToRequestWorks() throws {
        let data = "I'm a test string!".data(using: .utf8)!
        var request = Request(baseURL: self.testURL,
                              path: "data",
                              method: .PUT,
                              loggedIn: true,
                              token: self.testToken)
        request.bodyData = data
        
        let urlRequest = try request.toURLRequest()
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.test.nl/api/data")
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.PUT.rawValue)
        
        guard let bodyData = urlRequest.httpBody else {
            XCTFail("Body data was not added properly!")
            return
        }
        
        XCTAssertEqual(bodyData, data)
        
        guard let headers = urlRequest.allHTTPHeaderFields else {
            XCTFail("Could not access headers!")
            return
        }
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
        XCTAssertEqual(headers[HeaderKey.authorization.rawValue], "Bearer Testing!")
    }
    
    func testSettingAdditionalHeadersUpdatesHeaderDict() throws {
        var request = Request(baseURL: self.testURL,
                              path: "additional/headers",
                              loggedIn: true,
                              token: self.testToken)
        request.additionalHeaders = [ .contentType: .testing("TEST") ]
        
        let urlRequest = try request.toURLRequest()
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.test.nl/api/additional/headers")
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.GET.rawValue)
        XCTAssertNil(urlRequest.httpBody)
        
        guard let headers = urlRequest.allHTTPHeaderFields else {
            XCTFail("Could not access headers!")
            return
        }
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers[HeaderKey.contentType.rawValue], "TEST")
        XCTAssertEqual(headers[HeaderKey.authorization.rawValue], "Bearer Testing!")
    }
    
    func testCreatingRequestWithQueryItems() throws {
        let queryParams = [
            URLQueryItem(name: "test_key", value: "Test Value"),
            URLQueryItem(name: "date", value: "2019-05-08")
        ]
        
        let request = Request(baseURL: self.testURL,
                              path: "query/params",
                              queryItems: queryParams,
                              loggedIn: false,
                              token: self.testToken)
        
        let urlRequest = try request.toURLRequest()
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.GET.rawValue)
        XCTAssertNil(urlRequest.httpBody)
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://www.test.nl/api/query/params?test_key=Test%20Value&date=2019-05-08")
        guard let headers = urlRequest.allHTTPHeaderFields else {
            XCTFail("Could not access headers!")
            return
        }
        
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(headers[HeaderKey.contentType.rawValue], HeaderValue.applicationJSON.toString)
    }
}
