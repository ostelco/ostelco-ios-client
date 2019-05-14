//
//  PrimeAPI.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import Foundation

/// A class to wrap APIs controlled by the Prime backend.
open class PrimeAPI: BasicNetwork {
    
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
    
    /// Uploads the device's push token to the server.
    ///
    /// - Parameter pushToken: The push token to send
    /// - Returns: A promise which, when fulfilled, indicates the token was sent successfully.
    public func sendPushToken(_ pushToken: PushToken) -> Promise<Void> {
        return self.sendObject(pushToken, to: RootEndpoint.applicationToken.value, method: .POST)
            .map { data, response in
                try APIHelper.validateAndLookForServerError(data: data, response: response, decoder: self.decoder)
            }
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
        let queryItem = URLQueryItem(name: "sourceId", value: payment.sourceId)

        return self.sendQuery(to: path, queryItems: [ queryItem ], method: .POST)
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
        let queryItems = [
            URLQueryItem(name: "nickname", value: userSetup.nickname),
            URLQueryItem(name: "contactEmail", value: userSetup.contactEmail)
        ]
        return self.sendQuery(to: RootEndpoint.customer.value, queryItems: queryItems, method: .POST)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response, decoder: self.decoder)
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
                return self.performValidatedRequest(request, decoder: self.decoder, dataCanBeEmpty: true)
            }
            .done { data in
                let dataString = String(bytes: data, encoding: .utf8)
                debugPrint("Delete customer response: \(String(describing: dataString))")
        }
    }

    /// - Returns: A Promise which when fulfilled will contain the Stripe Ephemeral Key
    public func stripeEphemeralKey(stripeAPIVersion: String) -> Promise<[String: AnyObject]?> {
        let path = RootEndpoint.customer.pathByAddingEndpoints([CustomerEndpoint.stripeEphemeralKey])
        let apiQueryItem = URLQueryItem(name: "api_version", value: stripeAPIVersion)
        return self.loadData(from: path, queryItems: [apiQueryItem])
            .map { try JSONSerialization.jsonObject(with: $0, options: []) as? [String: AnyObject] }
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
    
    /// Creates a SIM profile for the given region
    ///
    /// - Parameter code: The region code to use
    /// - Returns: A promise which, when fulfilled, will contain the created SIM profile.
    public func createSimProfileForRegion(code: String) -> Promise<SimProfile> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .simProfiles
        ]
    
        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)
        let queryItem = URLQueryItem(name: "profileType", value: SimProfileRequest().profileType)

        return self.sendQuery(to: path, queryItems: [ queryItem ], method: .POST)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response, decoder: self.decoder)
            }
            .map { try self.decoder.decode(SimProfile.self, from: $0) }
    }
    
    /// Creates a Jumio scan request for the given region
    ///
    /// - Parameter code: The region to request a Jumio scan request for
    /// - Returns: A promise which when fulfilled contains the requested data
    public func createJumioScanForRegion(code: String) -> Promise<Scan> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .kyc,
            .jumio,
            .scans,
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)
        
        return self.tokenProvider.getToken()
            .map { Request(baseURL: self.baseURL,
                           path: path,
                           method: .POST,
                           loggedIn: true,
                           token: $0)
            }
            .then { self.performValidatedRequest($0, decoder: self.decoder) }
            .map { try self.decoder.decode(Scan.self, from: $0) }
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
        let queryItems = [
            URLQueryItem(name: "address", value: address.address),
            URLQueryItem(name: "phoneNumber", value: address.phoneNumber)
        ]

        return self.sendQuery(to: path, queryItems: queryItems, method: .PUT)
            .done { data, response in
                try APIHelper.validateAndLookForServerError(data: data, response: response, decoder: self.decoder, dataCanBeEmpty: true)
            }
    }
    
    /// Updates the user's EKYC profile with the given information in the given region.
    ///
    /// - Parameters:
    ///   - update: The info to be updated.
    ///   - code: The region to update the user profile in
    /// - Returns: A promise which when fulfilled, indicates successful completion of the operation.
    public func updateEKYCProfile(with update: EKYCProfileUpdate, forRegion code: String) -> Promise<Void> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .kyc,
            .profile
        ]

        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)
        let queryItems = [
            URLQueryItem(name: "address", value: update.address),
            URLQueryItem(name: "phoneNumber", value: update.phoneNumber)
        ]

        return self.sendQuery(to: path, queryItems: queryItems, method: .PUT)
            .map { data, response in
                try APIHelper.validateAndLookForServerError(data: data,
                                                            response: response,
                                                            decoder: self.decoder)
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
        
        return self.loadData(from: path)
            .map { _ in
                return true
            }
            .recover { error -> Promise<Bool> in
                switch error {
                case APIHelper.Error.jsonError(let jsonError):
                    if jsonError.errorCode == "INVALID_NRIC_FIN_ID" {
                        return .value(false)
                    }
                default:
                    break
                }
                
                // If we got here, re-throw the error.
                throw error
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

    /// Loads configuration details of MyInfo sign in (singapore only!)
    ///
    /// - Returns: A promise which, when fulfilled, will contain the user's `MyInfoConfig`.
    public func loadMyInfoConfig() -> Promise<MyInfoConfig> {
        let myInfoEndpoints: [RegionEndpoint] = [
            .region(code: "sg"),
            .kyc,
            .myInfoConfig
        ]

        let path = RootEndpoint.regions.pathByAddingEndpoints(myInfoEndpoints)

        return self.loadData(from: path)
            .map { try self.decoder.decode(MyInfoConfig.self, from: $0) }
    }

    // MARK: - General
    
    /// Loads arbitrary data from a path based on the base URL, then validates
    /// that the response is valid.
    ///
    /// - Parameter path: The path to load data from
    /// - Returns: A promise, which when fulfilled, will contain the loaded data.
    public func loadData(from path: String, queryItems: [URLQueryItem]? = nil) -> Promise<Data> {
        return self.tokenProvider.getToken()
            .map { Request(baseURL: self.baseURL,
                           path: path,
                           queryItems: queryItems,
                           loggedIn: true,
                           token: $0) }
            .then { self.performValidatedRequest($0, decoder: self.decoder) }
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

    /// Sends a request with query parameters to the given path based on the base URL.
    /// NOTE: Does not validate directly, since we may need to parse error data which comes back.
    ///
    /// - Parameters:
    ///   - path: The path to send it to
    ///   - queryItems: The query parameters to send.
    ///   - method: The `HTTPMethod` to use to send it.
    /// - Returns: A promise, which when fulfilled, will contain any returned data and the URLResponse that came with it.
    public func sendQuery(to path: String,
                          queryItems: [URLQueryItem],
                          method: HTTPMethod) -> Promise<(data: Data, response: URLResponse)> {
        return self.tokenProvider.getToken()
            .map { token -> Request in
                return Request(baseURL: self.baseURL,
                               path: path,
                               method: method,
                               queryItems: queryItems,
                               loggedIn: true,
                               token: token)
            }
            .then {
                self.performRequest($0)
            }
    }
}
