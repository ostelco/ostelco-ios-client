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
open class LoggedInAPI: BasicNetwork {
    
    enum Error: Swift.Error, LocalizedError {
        case failedToGetRegion
        
        var localizedDescription: String {
            switch self {
            case .failedToGetRegion:
                return "Could not find suitable region from region response"
            }
        }
    }
    
    private let baseURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let secureStorage: SecureStorage
    
    /// Designated Initializer.
    ///
    /// - Parameters:
    ///   - baseURL: The URL string to use to construct the base URL. If
    ///              the passed in string does not resolve to a valid URL,
    ///              a fatal error will be thrown
    ///   - secureStorage: The `SecureStorage` instance to use to access user creds.
    public init(baseURL: String,
                secureStorage: SecureStorage) {
        guard let url = URL(string: baseURL) else {
            fatalError("Could not create base URL from passed-in string \(baseURL)")
        }
        
        self.baseURL = url
        self.secureStorage = secureStorage
    }
    
    /// - Returns: A Promise which which when fulfilled will contain the user's bundle models
    public func loadBundles() -> Promise<[BundleModel]> {
        return self.loadData(from: RootEndpoint.bundles.rawValue)
            .map { try self.decoder.decode([BundleModel].self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's purchase models
    public func loadPurchases() -> Promise<[PurchaseModel]> {
        return self.loadData(from: RootEndpoint.purchases.rawValue)
            .map { try self.decoder.decode([PurchaseModel].self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's proile model
    public func loadProfile() -> Promise<ProfileModel> {
        return self.loadData(from: RootEndpoint.profile.rawValue)
            .map { try self.decoder.decode(ProfileModel.self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's product models
    public func loadProducts() -> Promise<[ProductModel]> {
        return self.loadData(from: RootEndpoint.products.rawValue)
            .map { try self.decoder.decode([ProductModel].self, from: $0) }
    }

    /// - Returns: A promise which when fulfilled will contain all region responses for this user
    public func loadRegions() -> Promise<[RegionResponse]> {
        return self.loadData(from: RootEndpoint.regions.rawValue)
            .map { try self.decoder.decode([RegionResponse].self, from: $0) }
    }

    /// - Returns: A promise which when fulfilled will contain the relevant region response for this user.
    public func getRegionFromRegions() -> Promise<RegionResponse> {
        return self.loadRegions()
            .map { regions -> RegionResponse in
                guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
                    throw Error.failedToGetRegion
                }
                
                return region
            }
    }
    
    /// Loads arbitrary data from an endpoint based on the base URL, then validates
    /// that the response is valid.
    ///
    /// Note: Override this method in a subclass to provide mock data to the other methods.
    ///
    /// - Parameter endpoint: The endpoint to load data from
    /// - Returns: A promise, which when fulfilled, will contain the loaded data.
    open func loadData(from path: String) -> Promise<Data> {
        let request = Request(baseURL: self.baseURL,
                              path: path,
                              loggedIn: true,
                              secureStorage: self.secureStorage)
        
        return self.performValidatedRequest(request)
    }
    
    open func sendObject<T: Codable>(_ object: T, to path: String, method: HTTPMethod) -> Promise<(data: Data, response: URLResponse)> {
        return APIHelper.encode(object, with: self.encoder)
            .map { data -> Request in
                var request = Request(baseURL: self.baseURL,
                                      path: path,
                                      method: method,
                                      loggedIn: true,
                                      secureStorage: self.secureStorage)
                
                request.bodyData = data
                return request
            }
            .then {
                self.performRequest($0)
            }
    }
}
