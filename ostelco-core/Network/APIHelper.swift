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
public struct APIHelper {
    
    /// Errors thrown by the API helper
    ///
    /// - invalidResponseType: The response received was not an HTTP Response. Includes the data returned as a parameter.
    /// - invalidResponseCode: The response received did not have a code between 200-300. Includes the data returned as a parameter.
    /// - dataWasEmpty: The data in the response was empty.
    /// - errorCameWithoutData: An expected error came without data to back it up
    public enum Error: Swift.Error {
        case invalidResponseType(data: Data)
        case invalidResponseCode(_ code: Int, data: Data)
        case dataWasEmpty
        case errorCameWithoutData
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
    
    public static func encode<T: Codable>(_ object: T, with encoder: JSONEncoder) -> Promise<Data> {
        do {
            let data = try encoder.encode(object)
            return .value(data)
        } catch {
            return Promise(error: error)
        }
    }
}
