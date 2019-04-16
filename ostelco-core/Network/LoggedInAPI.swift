//
//  LoggedInAPI.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import Foundation


/// A class to wrap APIs called once the user is logged in. 
open class LoggedInAPI {
    
    private let baseURL: URL
    private let decoder = JSONDecoder()
    
    /// Designated Initializer.
    ///
    /// - Parameter baseURL: The URL string to use to construct the base URL. If
    ///                      the passed in string does not resolve to a valid URL,
    ///                      a fatal error will be thrown
    public init(baseURL: String) {
        guard let url = URL(string: baseURL) else {
            fatalError("Could not create base URL from passed-in string \(baseURL)")
        }
        
        self.baseURL = url
    }
    
    /// - Returns: A Promise which which when fulfilled will contain the user's bundle models
    public func loadBundles() -> Promise<[BundleModel]> {
        return self.loadData(from: "bundles")
            .map { try self.decoder.decode([BundleModel].self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's purchase models
    public func loadPurchases() -> Promise<[PurchaseModel]> {
       return self.loadData(from: "purchases")
            .map { try self.decoder.decode([PurchaseModel].self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's proile model
    public func loadProfile() -> Promise<ProfileModel> {
        return self.loadData(from: "profile")
            .map { try self.decoder.decode(ProfileModel.self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's product models
    public func loadProducts() -> Promise<[ProductModel]> {
        return self.loadData(from: "products")
            .map { try self.decoder.decode([ProductModel].self, from: $0) }
    }

    /// Loads arbitrary data from an endpoint based on the base URL, then validates
    /// that the response is valid.
    /// 
    /// Note: Override this method in a subclass to provide mock data to the other methods.
    ///
    /// - Parameter endpoint: The endpoint to load data from
    /// - Returns: A promise, which when fulfilled, will contain the loaded data.
    open func loadData(from endpoint: String) -> Promise<Data> {
        let url = self.baseURL.appendingPathComponent(endpoint)
        // TODO: Figure out how to get the user's token here
        return URLSession.shared.dataTask(.promise, with: url)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response)
            }
    }
}
