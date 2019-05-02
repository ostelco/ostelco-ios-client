//
//  RequestBuilder.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit

public struct Request {
    
    public let baseURL: URL
    public let endpoint: String
    public let loggedIn: Bool
    public let secureStorage: SecureStorage
    public let method: HTTPMethod
    
    public init(baseURL: URL,
                endpoint: String,
                method: HTTPMethod = .GET,
                loggedIn: Bool,
                secureStorage: SecureStorage) {
        self.baseURL = baseURL
        self.endpoint = endpoint
        self.method = method
        self.loggedIn = loggedIn
        self.secureStorage = secureStorage
    }
    
    public var additionalHeaders: [HeaderKey: HeaderValue]?
    public var bodyData: Data?
    
    public func generateRequest() -> Promise<URLRequest> {
        let url = self.baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        
        do {
            var headers = try Headers(loggedIn: self.loggedIn, secureStorage: self.secureStorage)
            
            if let additional = self.additionalHeaders {
                additional.forEach { key, value in headers.addValue(value, for: key) }
            }
            
            request.allHTTPHeaderFields = headers.toStringDict
            if let body = self.bodyData {
                request.httpBody = body
            }
            
            return .value(request)
        } catch {
            return Promise(error: error)
        }
    }
}
