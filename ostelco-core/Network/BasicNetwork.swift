//
//  BasicNetwork.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit

open class BasicNetwork {
    
    /// Performs a request and hands back the data and response it gets. Only if a system-level error
    /// occurs will this be piped into an Error.
    ///
    /// Note: Override this method in a subclass to provide mock data to the other methods.
    ///
    /// - Parameter request: The request to execute
    /// - Returns: The promise, which when fulfilled, will return the data and the URLResponse received.
    open func performRequest(_ request: Request) -> Promise<(data: Data, response: URLResponse)> {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.toURLRequest()
        } catch {
            return Promise(error: error)
        }
        
        return URLSession.shared.dataTask(.promise, with: urlRequest)
    }
    
    /// Performs a request, then validates that the response is in the expected status code range.
    /// If the response is not a valid status code or the data is unexpectedly empty an error will be thrown
    ///
    /// - Parameters:
    ///   - request: The request to execute
    ///   - dataCanBeEmpty: If returned data can be empty. Defaults to false.
    /// - Returns: The promise, which when fulfilled will return the data received.
    open func performValidatedRequest(_ request: Request, dataCanBeEmpty: Bool = false) -> Promise<Data> {
        return self.performRequest(request)
            .map { data, response in
                try APIHelper.validateResponse(data: data,
                                               response: response,
                                               dataCanBeEmpty: dataCanBeEmpty)
            }
    }
}
