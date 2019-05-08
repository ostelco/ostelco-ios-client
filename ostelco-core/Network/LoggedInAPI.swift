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
    private let tokenProvider: TokenProvider
    
    /// Designated Initializer.
    ///
    /// - Parameters:
    ///   - baseURL: The URL string to use to construct the base URL. If
    ///              the passed in string does not resolve to a valid URL,
    ///              a fatal error will be thrown
    ///   - tokenProvider: The `TokenProvider` instance to use to access user creds.
    public init(baseURL: String,
                tokenProvider: TokenProvider) {
        guard let url = URL(string: baseURL) else {
            fatalError("Could not create base URL from passed-in string \(baseURL)")
        }
        
        self.baseURL = url
        self.tokenProvider = tokenProvider
    }
    
    /// - Returns: A Promise which which when fulfilled will contain the user's bundle models
    public func loadBundles() -> Promise<[BundleModel]> {
        return self.loadData(from: RootEndpoint.bundles.value)
            .map { try self.decoder.decode([BundleModel].self, from: $0) }
    }

    /// - Returns: A promise which when fulfilled will contain the current context.
    public func loadContext() -> Promise<Context> {
        return self.loadData(from: RootEndpoint.context.value)
            .map { try self.decoder.decode(Context.self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's purchase models
    public func loadPurchases() -> Promise<[PurchaseModel]> {
        return self.loadData(from: RootEndpoint.purchases.value)
            .map { try self.decoder.decode([PurchaseModel].self, from: $0) }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's proile model
    public func loadProfile() -> Promise<ProfileModel> {
        return self.loadData(from: RootEndpoint.profile.value)
            .map { try self.decoder.decode(ProfileModel.self, from: $0) }
    }
    
    // MARK: - Products
    
    /// - Returns: A Promise which when fulfilled will contain the user's product models
    public func loadProducts() -> Promise<[ProductModel]> {
        return self.loadData(from: RootEndpoint.products.value)
            .map { try self.decoder.decode([ProductModel].self, from: $0) }
    }
    
    /// Purchases a product with the given SKU and the given payment information
    ///
    /// - Parameters:
    ///   - sku: The SKU to purchase
    ///   - payment: The payment information to use to purchase it
    /// - Returns: A Promise which when fulfilled will inidicate the purchase was successful
    public func purchaseProduct(with sku: String, payment: PaymentInfo) -> Promise<Void> {
        let productEndpoints: [ProductEndpoint] = [
            .sku(sku),
            .purchase
        ]
        
        let path = RootEndpoint.products.pathByAddingEndpoints(productEndpoints)
        
        return self.sendObject(payment, to: path, method: .POST)
            .done { data, response in
                try APIHelper.validateAndLookForServerError(data: data,
                                                            response: response,
                                                            decoder: self.decoder,
                                                            dataCanBeEmpty: true)
            }
    }
    
    // MARK: - Customer
    
    /// Creates a customer with the given data.
    ///
    /// - Parameter userSetup: The `UserSetup` to use.
    /// - Returns: A promise which when fullfilled will contain the created customer model.
    public func createCustomer(with userSetup: UserSetup) -> Promise<CustomerModel> {
        return self.sendObject(userSetup, to: RootEndpoint.customer.value, method: .POST)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response)
            }
            .map { try self.decoder.decode(CustomerModel.self, from: $0) }
    }
    
    /// Deletes the logged in customer.
    ///
    /// - Returns: A promise which when fulfilled, indicates successful deletion.
    public func deleteCustomer() -> Promise<Void> {
        return self.tokenProvider.getToken()
            .then { token -> Promise<Data> in
                let request = Request(baseURL: self.baseURL,
                                      path: RootEndpoint.customer.value,
                                      method: .DELETE,
                                      loggedIn: true,
                                      token: token)
                return self.performValidatedRequest(request, dataCanBeEmpty: true)
            }
            .done { data in
                let dataString = String(bytes: data, encoding: .utf8)
                debugPrint("Delete customer response: \(String(describing: dataString))")
        }
    }
    
    // MARK: - Regions

    /// - Returns: A promise which when fulfilled will contain all region responses for this user
    public func loadRegions() -> Promise<[RegionResponse]> {
        return self.loadData(from: RootEndpoint.regions.value)
            .map { try self.decoder.decode([RegionResponse].self, from: $0) }
    }
    
    /// Loads the region response for the specified region
    ///
    /// - Parameter code: The region to request
    /// - Returns: A promise which when fulfilled contains the requested region.
    public func loadRegion(code: String) -> Promise<RegionResponse> {
        let path = RootEndpoint.regions.pathByAddingEndpoints([RegionEndpoint.region(code: code)])
        
        return self.loadData(from: path)
            .map { try self.decoder.decode(RegionResponse.self, from: $0) }
    }
    
    /// Loads the SIM profiles for the specified region
    ///
    /// - Parameter code: The region to request SIM profiles for
    /// - Returns: A promise which when fullfilled contains the requested profiles
    public func loadSimProfilesForRegion(code: String) -> Promise<[SimProfile]> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .simProfiles
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)
        
        return self.loadData(from: path)
            .map { try self.decoder.decode([SimProfile].self, from: $0) }
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
    
    /// Adds the given address for the user in the given region
    ///
    /// - Parameters:
    ///   - address: The `EKYCAddress` to add.
    ///   - regionCode: The region to add the address for.
    /// - Returns: A promise which, when fulfilled, indicates successful completion of the operation.
    public func addAddress(_ address: EKYCAddress,
                           forRegion regionCode: String) -> Promise<Void> {
        let profileEndpoints: [RegionEndpoint] = [
            .region(code: regionCode),
            .kyc,
            .profile
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(profileEndpoints)
        
        return self.sendObject(address, to: path, method: .PUT)
            .done { data, response in
                try APIHelper.validateAndLookForServerError(data: data, response: response, decoder: self.decoder, dataCanBeEmpty: true)
            }
    }
    
    /// Validates the given NRIC.
    ///
    /// - Parameters:
    ///   - nric: The NRIC to validate
    ///   - regionCode: The region code to use to create the call.
    /// - Returns: A promise, which, when fulfilled, will return true if the NRIC is valid and false if not.
    public func validateNRIC(_ nric: String,
                             forRegion regionCode: String) -> Promise<Bool> {
        let nricEndpoints: [RegionEndpoint] = [
            .region(code: regionCode),
            .kyc,
            .dave,
            .nric(number: nric)
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(nricEndpoints)
        
        return self.loadNonValidatedData(from: path)
            .map { data, response in
                do {
                    try APIHelper.validateAndLookForServerError(data: data, response: response, decoder: self.decoder, dataCanBeEmpty: false)
                    return true
                } catch {
                    switch error {
                    case APIHelper.Error.jsonError(let jsonError):
                        if jsonError.errorCode == "INVALID_NRIC_FIN_ID" {
                            return false
                        }
                    default:
                        break
                    }
                    
                    // If we got here, re-throw the error.
                    throw error
                }
            }
    }
    
    /// Loads details based on a SingPass sign in (singapore only!)
    ///
    /// - Parameter code: The code associated with the user in SingPass
    /// - Returns: A promise which, when fulfilled, will contain the user's `MyInfoDetails`.
    public func loadSingpassInfo(code: String) -> Promise<MyInfoDetails> {
        let myInfoEndpoints: [RegionEndpoint] = [
            .region(code: "sg"),
            .kyc,
            .myInfo,
            .myInfoCode(code: code)
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(myInfoEndpoints)
        
        return self.loadData(from: path)
            .map { try self.decoder.decode(MyInfoDetails.self, from: $0) }
    }
    
    // MARK: - General
    
    /// Loads arbitrary data from a path based on the base URL, then validates
    /// that the response is valid.
    ///
    /// - Parameter path: The path to load data from
    /// - Returns: A promise, which when fulfilled, will contain the loaded data.
    public func loadData(from path: String) -> Promise<Data> {
        return self.tokenProvider.getToken()
            .then { token -> Promise<Data> in
                let request = Request(baseURL: self.baseURL,
                                      path: path,
                                      loggedIn: true,
                                      token: token)
                return self.performValidatedRequest(request)
            }
    }
    
    public func loadNonValidatedData(from path: String) -> Promise<(data: Data, response: URLResponse)> {
        return self.tokenProvider.getToken()
            .then { token -> Promise<(data: Data, response: URLResponse)> in
                let request = Request(baseURL: self.baseURL,
                                      path: path,
                                      loggedIn: true,
                                      token: token)
                return self.performRequest(request)
            }
    }
    
    /// Sends `Codable` object to the given path based on the base URL.
    /// NOTE: Does not validate directly, since we may need to parse error data which comes back.
    ///
    /// - Parameters:
    ///   - object: The object to send
    ///   - path: The path to send it to
    ///   - method: The `HTTPMethod` to use to send it.
    /// - Returns: A promise, which when fulfilled, will contain any returned data and the URLResponse that came with it.
    public func sendObject<T: Codable>(_ object: T, to path: String, method: HTTPMethod) -> Promise<(data: Data, response: URLResponse)> {
        return self.tokenProvider.getToken()
            .map { token -> Request in
                let data = try self.encoder.encode(object)
                var request = Request(baseURL: self.baseURL,
                                      path: path,
                                      method: method,
                                      loggedIn: true,
                                      token: token)
                
                request.bodyData = data
                return request
            }
            .then {
                self.performRequest($0)
            }
    }
}
