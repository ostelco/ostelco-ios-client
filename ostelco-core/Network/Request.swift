//
//  RequestBuilder.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct Request {
    
    enum Error: Swift.Error {
        case couldntConstructURLFromComponents
    }
    
    public let baseURL: URL
    public let path: String
    public let loggedIn: Bool
    public let token: String?
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    
    public init(baseURL: URL,
                path: String,
                method: HTTPMethod = .GET,
                queryItems: [URLQueryItem]? = nil,
                loggedIn: Bool,
                token: String?) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.loggedIn = loggedIn
        self.token = token
    }
    
    public var additionalHeaders: [HeaderKey: HeaderValue]?
    public var bodyData: Data?
    
    public func toURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: self.baseURL.appendingPathComponent(self.path).absoluteString)
        urlComponents?.queryItems = self.queryItems
        guard let url = urlComponents?.url else {
            throw Error.couldntConstructURLFromComponents
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.timeoutInterval = 180.0
        
        var headers = try Headers(loggedIn: self.loggedIn, token: self.token)

        if let additional = self.additionalHeaders {
            additional.forEach { key, value in headers.addValue(value, for: key) }
        }
        
        request.allHTTPHeaderFields = headers.toStringDict
        if let body = self.bodyData {
            request.httpBody = body
        }
        
        return request
    }
}
