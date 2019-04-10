//
//  APIHelper.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit

/// Reusable helper to handle validation across APIs
struct APIHelper {
    
    enum Error: Swift.Error {
        case invalidResponseType(data: Data)
        case invalidResponseCode(_ code: Int, data: Data)
        case dataWasEmpty
    }
    
    /// Validates the data and URLResponse received from NSURLSession
    ///
    /// - Parameters:
    ///   - data: The data received from NSURLSession
    ///   - response: The response received from NSURLSession
    ///   - dataCanBeEmpty: True if the data can be empty, false if not. Defaults to false.
    /// - Returns: The valid data.
    /// - Throws: Throws an error if the URLResponse is not an HTTPURLResponse, the status
    ///           code is invalid, or the data was empty without permission.
    public static func validateResponse(data: Data, response: URLResponse, dataCanBeEmpty: Bool = false) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponseType(data: data)
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            // Valid response code
            break
        default:
            throw Error.invalidResponseCode(httpResponse.statusCode, data: data)
        }

        if !dataCanBeEmpty {
            guard data.isNotEmpty else {
                throw Error.dataWasEmpty
            }
        }

        return data
    }
}

