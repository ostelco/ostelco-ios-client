//
//  Headers.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

/// Keys to include in headers. The raw value is the key for a header dict.
public enum HeaderKey: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case testing = "Testing"
}

/// Values to include in headers.
/// `toString` is the value which should be included in a header dictionary.
public enum HeaderValue {
    case applicationJSON
    case token(String)
    case testing(String)
    
    public var toString: String {
        switch self {
        case .applicationJSON:
            return "application/json"
        case .token(let token):
            return "Bearer \(token)"
        case .testing(let testString):
            return testString
        }
    }
}

/// A structure to facilitate creating headers for API calls.
public struct Headers {
    
    /// Any error which can occur constructing headers.
    public enum Error: Swift.Error, LocalizedError {
        case noTokenForLoggedInRequest
        
        var localizedDescription: String {
            switch self {
            case .noTokenForLoggedInRequest:
                return "We are not able to access the login token at this time."
            }
        }
    }
    
    private var headerDict = [HeaderKey: HeaderValue]()
    
    /// Outputs underlying typed dictionary to a string dictionary so it can be sent with requests.
    public var toStringDict: [String: String] {
        var stringDict = [String: String]()
        self.headerDict.forEach { key, value in
            stringDict[key.rawValue] = value.toString
        }
        
        return stringDict
    }
    
    /// Factory method to generate default headers
    ///
    /// - Parameters:
    ///   - loggedIn: True if the user should be logged in for this call, false if not
    ///   - token: The authorization token to use to construct the headers, if one exists.
    /// - Returns: The generated headers
    /// - Throws: When headers cannot be constructed.
    public init(loggedIn: Bool, token: String?) throws {
        self.addValue(.applicationJSON, for: .contentType)
        
        if loggedIn {
            guard let token = token else {
                throw Error.noTokenForLoggedInRequest
            }
            
            self.addValue(.token(token), for: .authorization)
        } // else adding auth is not necessary.
    }
    
    /// Adds the given value for the given key.
    /// Note: Will replace existing values if a value for that key already exists.
    ///
    /// - Parameters:
    ///   - value: The value to add or replace.
    ///   - key: The key to add or replace the value for.
    mutating public func addValue(_ value: HeaderValue, for key: HeaderKey) {
        self.headerDict[key] = value
    }
}
