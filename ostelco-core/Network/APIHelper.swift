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
    public enum Error: Swift.Error, LocalizedError {
        case dataWasEmpty
        case expectedServerErrorNotFound(data: Data)
        case invalidResponseType(data: Data)
        case invalidResponseCode(_ code: Int, data: Data)
        case jsonError(_ error: JSONRequestError)
        case serverError(_ error: ServerError)
        case unexpectedResponseFormat(data: Data)
        
        var localizedDescription: String {
            switch self {
            case .dataWasEmpty:
                return "Data was empty when we expected it to not be empty."
            case .expectedServerErrorNotFound(let data):
                let dataString = String(bytes: data, encoding: .utf8)
                return """
                We expected an error, but did not recieve one.
                Data received as string:
                \(String(describing: dataString))
                """
            case .invalidResponseType(let data):
                let dataString = String(bytes: data, encoding: .utf8)
                return """
                The response received was not an HTTP response.
                Data receieved as string:
                \(String(describing: dataString))
                """
            case .invalidResponseCode(let code, let data):
                let dataString = String(bytes: data, encoding: .utf8)
                return """
                Received invalid \(code) status code from the server.
                Data received as string:
                \(String(describing: dataString))
                """
            case .jsonError(let error):
                return """
                Received server error:
                - Status Code: \(error.httpStatusCode)
                - Error Code: \(error.errorCode)
                - Message: \(error.message)
                """
            case .serverError(let error):
                return """
                Received server error(s):
                - \(error.errors.joined(separator: "\n- "))
                """
            case .unexpectedResponseFormat(let data):
                let dataString = String(bytes: data, encoding: .utf8)
                return """
                We were expecting a different format than was received.
                Data received as string:
                \(String(describing: dataString))
                """
            }
        }
    }
    
    /// Validates the data and URLResponse received from URLSession
    ///
    /// - Parameters:
    ///   - data: The data received from URLSession
    ///   - response: The response received from URLSession
    ///   - decoder: The JSON decoder to use to try to parse errors from invalid response codes.
    ///   - dataCanBeEmpty: True if the data can be empty, false if not. Defaults to false.
    /// - Returns: The valid data.
    /// - Throws: Throws an error if the URLResponse is not an HTTPURLResponse, the status
    ///           code is invalid, or the data was empty without permission.
    public static func validateResponse(data: Data,
                                        response: URLResponse,
                                        decoder: JSONDecoder,
                                        dataCanBeEmpty: Bool = false) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponseType(data: data)
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            // Valid response code
            break
        default:
            if let parsedError = self.createOptionalError(from: data, decoder: decoder) {
                throw parsedError
            } else {
                throw Error.invalidResponseCode(httpResponse.statusCode, data: data)
            }
        }
        
        if !dataCanBeEmpty {
            guard data.isNotEmpty else {
                throw Error.dataWasEmpty
            }
        }
        
        return data
    }
    
    /// Attempts to create an error based on returned data. Returns nil if data can't be parsed.
    ///
    /// - Parameters:
    ///   - data: The data to decode
    ///   - decoder: The decoder to use to try to decode it
    /// - Returns: An error if found, or nil.
    public static func createOptionalError(from data: Data, decoder: JSONDecoder) -> Error? {
        if let serverError = try? decoder.decode(ServerError.self, from: data) {
            return APIHelper.Error.serverError(serverError)
        } else if let jsonError = try? decoder.decode(JSONRequestError.self, from: data) {
            return APIHelper.Error.jsonError(jsonError)
        } else {
            return nil
        }
    }
    
    /// Creates a non-optional error based on the returned data. Should only be used if error JSON is expected
    ///
    /// - Parameters:
    ///   - data: The data returned from the server
    ///   - decoder: The JSONDecoder to use to parse the JSON
    /// - Returns: An error to be thrown
    public static func createError(from data: Data, decoder: JSONDecoder) -> Error {
        if let error = self.createOptionalError(from: data, decoder: decoder) {
            return error
        } else {
            return APIHelper.Error.expectedServerErrorNotFound(data: data)
        }
    }
    
    /// Validates received data, then searches for a server-returned error type if validation fails.
    ///
    /// - Parameters:
    ///   - data: The data to validate
    ///   - response: The response to validate
    ///   - decoder: The decoder to use to try to parse server errors
    ///   - dataCanBeEmpty: If the data is valid if it's empty. Defaults to true.
    /// - Throws: If the response is not valid.
    public static func validateAndLookForServerError(data: Data,
                                                     response: URLResponse,
                                                     decoder: JSONDecoder,
                                                     dataCanBeEmpty: Bool = true) throws {
        do {
            _ = try APIHelper.validateResponse(data: data,
                                               response: response,
                                               decoder: decoder,
                                               dataCanBeEmpty: dataCanBeEmpty)
        } catch {
            switch error {
            case APIHelper.Error.invalidResponseCode(_, let data):
                throw self.createError(from: data, decoder: decoder)
            case APIHelper.Error.invalidResponseType(let data):
                throw self.createError(from: data, decoder: decoder)
            default:
                throw error
            }
        }
    }
}
