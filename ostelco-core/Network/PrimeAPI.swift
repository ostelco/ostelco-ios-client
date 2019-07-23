//
//  PrimeAPI.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import Foundation
import Apollo

public typealias Long = Int64

extension Int64: JSONDecodable, JSONEncodable {
    public init(jsonValue value: JSONValue) throws {
        debugPrint(value)
        if let longValue = value as? Int64 {
            // If this is integer, grab it
            self = longValue
        } else {
            // Otherwise convert form a string
            guard let string = value as? String else {
                throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
            }
            guard let number = Int64(string) else {
                throw JSONDecodingError.couldNotConvert(value: value, to: Int64.self)
            }
            self = number
        }
    }

    public var jsonValue: JSONValue {
        return String(self)
    }
}

/// A class to wrap APIs controlled by the Prime backend.
open class PrimeAPI: BasicNetwork {
    
    public enum Error: Swift.Error, LocalizedError {
        case failedToGetRegion
        
        public var localizedDescription: String {
            switch self {
            case .failedToGetRegion:
                return "Could not find suitable region from region response"
            }
        }
    }
    
    public enum Mode {
        case rest
        case graphQL
    }
    
    private let baseURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let tokenProvider: TokenProvider
    private var token: String = ""

    // Configure the network transport to use the singleton as the delegate.
    private lazy var networkTransport = HTTPNetworkTransport(
        url: self.baseURL.appendingPathComponent(RootEndpoint.graphql.value, isDirectory: false),
        delegate: self
    )
    
    private(set) lazy var client = ApolloClient(networkTransport: self.networkTransport)

    /// Designated Initializer.
    ///
    /// - Parameters:
    ///   - baseURL: The URL string to use to construct the base URL. If
    ///              the passed in string does not resolve to a valid URL,
    ///              a fatal error will be thrown
    ///   - tokenProvider: The `TokenProvider` instance to use to access user creds.
    public init(baseURLString: String,
                tokenProvider: TokenProvider) {
        guard let url = URL(string: baseURLString) else {
            fatalError("Could not create base URL from passed-in string \(baseURLString)")
        }
        
        self.baseURL = url
        self.tokenProvider = tokenProvider
    }
    
    /// Uploads the device's push token to the server.
    ///
    /// - Parameter pushToken: The push token to send
    /// - Returns: A promise which, when fulfilled, indicates the token was sent successfully.
    public func sendPushToken(_ pushToken: PushToken) -> PromiseKit.Promise<Void> {
        return self.sendObject(pushToken, to: RootEndpoint.applicationToken.value, method: .POST)
            .map { data, response in
                try APIHelper.validateAndLookForServerError(data: data, response: response, decoder: self.decoder)
            }
    }
    
    /// - Returns: A Promise which which when fulfilled will contain the user's bundle models
    public func loadBundles() -> PromiseKit.Promise<[BundleModel]> {
        return self.getToken()
            .then { _ in
                return PromiseKit.Promise<[BundleModel]> { seal in
                    self.client.fetch(query: PrimeGQL.BundlesQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { (result, error) in
                        if let error = error {
                            seal.reject(error)
                            return
                        }
                        
                        var bundlesList: [BundleModel] = []
                        
                        if let data = result?.data {
                            if let bundles = data.context.bundles {
                                bundlesList = bundles.map({ BundleModel(gqlData: $0) })
                            }
                        }
                        
                        seal.fulfill(bundlesList)
                    }
                }
            }
    }

    /// - Returns: A promise which when fulfilled will contain the current context.
    public func loadContext() -> PromiseKit.Promise<Context> {
        return self.getToken()
        .then { _ in
            return PromiseKit.Promise<Context> { seal in
                self.client.fetch(query: PrimeGQL.ContextQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { (result, error) in
                    // TODO: Make sure we handle the case where we fetch context and there is no customer from server.
                    if let error = error {
                        seal.reject(error)
                        return
                    }
                    if let data = result?.data {
                        let customer = data.context.customer
                        var regionResponseList: [RegionResponse] = []
                        let customerModel = CustomerModel(gqlCustomer: customer)
                        
                        if let regions = data.context.regions {
                            regionResponseList = regions.compactMap({$0}).map({ RegionResponse(gqlData: $0.fragments.regionDetailsFragment) })
                        }
                        
                        seal.fulfill(Context(customer: customerModel, regions: regionResponseList))
                    } else {
                        // Note: RootCoordinator excepts an error of specific type to redirect user to signup when user is logged in but has not user in our server yet.
                        seal.reject(APIHelper.Error.jsonError(JSONRequestError(errorCode: "FAILED_TO_FETCH_CUSTOMER", httpStatusCode: 404, message: "Failed to fetch customer.")))
                    }
                }
                
            }
        }
    }
    
    /// - Returns: A Promise which when fulfilled will contain the user's purchase models
    public func loadPurchases() -> PromiseKit.Promise<[PurchaseModel]> {
        return self.getToken()
            .then { _ in
                return PromiseKit.Promise<[PurchaseModel]> { seal in
                    self.client.fetch(query: PrimeGQL.PurchasesQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { (result, error) in
                        if let error = error {
                            seal.reject(error)
                            return
                        }
                        
                        var resultList: [PurchaseModel] = []
                        
                        if let data = result?.data {
                            if let purchases = data.context.purchases {
                                resultList = purchases.map({ PurchaseModel(gqlData: $0) })
                            }
                        }
                        
                        seal.fulfill(resultList)
                    }
                }
            }
    }

    // MARK: - Products
    
    /// - Returns: A Promise which when fulfilled will contain the user's product models
    public func loadProducts() -> PromiseKit.Promise<[ProductModel]> {
        return self.getToken()
            .then { _ in
                return PromiseKit.Promise<[ProductModel]> { seal in
                    self.client.fetch(query: PrimeGQL.ProductsQuery(), cachePolicy: .fetchIgnoringCacheCompletely) { (result, error) in
                        if let error = error {
                            seal.reject(error)
                            return
                        }
                        
                        var resultList: [ProductModel] = []
                        
                        if let data = result?.data {
                            if let products = data.context.products {
                                resultList = products.compactMap({$0}).map({ ProductModel(gqlData: $0.fragments.productFragment) })
                            }
                        }
                        
                        seal.fulfill(resultList)
                    }
                }
        }
    }
    
    /// Purchases a product with the given SKU and the given payment information
    ///
    /// - Parameters:
    ///   - sku: The SKU to purchase
    ///   - payment: The payment information to use to purchase it
    /// - Returns: A Promise which when fulfilled will inidicate the purchase was successful
    public func purchaseProduct(with sku: String, payment: PaymentInfo) -> PromiseKit.Promise<Void> {
        let productEndpoints: [ProductEndpoint] = [
            .sku(sku),
            .purchase
        ]
        
        let path = RootEndpoint.products.pathByAddingEndpoints(productEndpoints)

        return self.sendQuery(to: path, queryItems: payment.asQueryItems, method: .POST)
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
    public func createCustomer(with userSetup: UserSetup) -> PromiseKit.Promise<CustomerModel> {
        return self.sendQuery(to: RootEndpoint.customer.value, queryItems: userSetup.asQueryItems, method: .POST)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response, decoder: self.decoder)
            }
            .map { try self.decoder.decode(CustomerModel.self, from: $0) }
    }
    
    /// Deletes the logged in customer.
    ///
    /// - Returns: A promise which when fulfilled, indicates successful deletion.
    public func deleteCustomer() -> PromiseKit.Promise<Void> {
        return self.tokenProvider.getToken()
            .then { token -> PromiseKit.Promise<Data> in
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

    // TODO: Convert to GraphQL
    /// - Returns: A Promise which when fulfilled will contain the Stripe Ephemeral Key
    public func stripeEphemeralKey(with request: StripeEphemeralKeyRequest) -> PromiseKit.Promise<[AnyHashable: Any]> {
        let path = RootEndpoint.customer.pathByAddingEndpoints([CustomerEndpoint.stripeEphemeralKey])
        return self.loadData(from: path, queryItems: request.asQueryItems)
            .map { data -> [AnyHashable: Any] in
                let object = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = object as? [AnyHashable: Any] else {
                    throw APIHelper.Error.unexpectedResponseFormat(data: data)
                }
                return dictionary
            }
    }

    // MARK: - Regions

    /// - Returns: A promise which when fulfilled will contain all region responses for this user
    public func loadRegions(countryCode: String? = nil) -> PromiseKit.Promise<[RegionResponse]> {
        return self.getToken()
            .then { _ in
                return PromiseKit.Promise<[RegionResponse]> { seal in
                    self.client.fetch(query: PrimeGQL.RegionsQuery(countryCode: countryCode), cachePolicy: .fetchIgnoringCacheCompletely) { (result, error) in
                        if let error = error {
                            seal.reject(error)
                            return
                        }
                        
                        var resultList: [RegionResponse] = []
                        
                        if let data = result?.data {
                            if let regions = data.context.regions {
                                resultList = regions.compactMap({$0}).map({ RegionResponse(gqlData: $0.fragments.regionDetailsFragment) })
                            }
                        }
                        
                        seal.fulfill(resultList)
                    }
                }
        }
    }
    
    /// Loads the region response for the specified region
    ///
    /// - Parameter code: The region to request
    /// - Returns: A promise which when fulfilled contains the requested region.
    public func loadRegion(code: String) -> PromiseKit.Promise<RegionResponse> {
        return loadRegions(countryCode: code).firstValue
    }
    
    // TODO: Load from GraphQL
    /// Loads the SIM profiles for the specified region
    ///
    /// - Parameter code: The region to request SIM profiles for
    /// - Returns: A promise which when fullfilled contains the requested profiles
    public func loadSimProfilesForRegion(code: String) -> PromiseKit.Promise<[SimProfile]> {
        return self.getToken()
        .then { _ in
            return PromiseKit.Promise { seal in
                self.client.fetch(query: PrimeGQL.SimProfilesForRegionQuery(countryCode: code)) { (result, error) in
                    if let error = error {
                        seal.reject(error)
                        return
                    }
                    
                    var resultList: [SimProfile] = []
                    
                    if let data = result?.data {
                        if let region = data.context.regions?.first, let simProfiles = region.simProfiles {
                            // TODO: Why does $0 (simProfile) not have fragments?
                            resultList = simProfiles.map({ SimProfile(gqlSimProfile: $0.fragments.simProfileFields) })
                        }
                    }
                    
                    seal.fulfill(resultList)
                }
            }
        }
    }
    
    /// Creates a SIM profile for the given region
    ///
    /// - Parameter code: The region code to use
    /// - Returns: A promise which, when fulfilled, will contain the created SIM profile.
    public func createSimProfileForRegion(code: String) -> PromiseKit.Promise<SimProfile> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .simProfiles
        ]
    
        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)

        return self.sendQuery(to: path, queryItems: SimProfileRequest().asQueryItems, method: .POST)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response, decoder: self.decoder)
            }
            .map { try self.decoder.decode(SimProfile.self, from: $0) }
    }
    
    // TODO: Load from GraphQL
    /// Resend QR code email for given sim profile
    ///
    /// - Parameters:
    ///     - code: The region code to use
    ///     - iccId: the iccId of the sim profile to resend QR code email
    /// - Returns: The sim profile with the given iccid
    public func resendEmailForSimProfileInRegion(code: String, iccId: String) -> PromiseKit.Promise<SimProfile> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .simProfiles,
            .iccId(code: iccId),
            .resendEmail
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)
        
        return self.loadData(from: path)
            .map { try self.decoder.decode(SimProfile.self, from: $0) }
    }
    
    /// Creates a Jumio scan request for the given region
    ///
    /// - Parameter code: The region to request a Jumio scan request for
    /// - Returns: A promise which when fulfilled contains the requested data
    public func createJumioScanForRegion(code: String) -> PromiseKit.Promise<Scan> {
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
    public func getRegionFromRegions() -> PromiseKit.Promise<RegionResponse> {
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
                           forRegion regionCode: String) -> PromiseKit.Promise<Void> {
        let profileEndpoints: [RegionEndpoint] = [
            .region(code: regionCode),
            .kyc,
            .profile
        ]

        let path = RootEndpoint.regions.pathByAddingEndpoints(profileEndpoints)

        return self.sendQuery(to: path, queryItems: address.asQueryItems, method: .PUT)
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
    public func updateEKYCProfile(with update: EKYCProfileUpdate, forRegion code: String) -> PromiseKit.Promise<Void> {
        let endpoints: [RegionEndpoint] = [
            .region(code: code),
            .kyc,
            .profile
        ]

        let path = RootEndpoint.regions.pathByAddingEndpoints(endpoints)

        return self.sendQuery(to: path, queryItems: update.asQueryItems, method: .PUT)
            .map { data, response in
                try APIHelper.validateAndLookForServerError(data: data,
                                                            response: response,
                                                            decoder: self.decoder)
            }
    }
    
    // TODO: Load from GraphQL
    /// Validates the given NRIC.
    ///
    /// - Parameters:
    ///   - nric: The NRIC to validate
    ///   - regionCode: The region code to use to create the call.
    /// - Returns: A promise, which, when fulfilled, will return true if the NRIC is valid and false if not.
    public func validateNRIC(_ nric: String,
                             forRegion regionCode: String) -> PromiseKit.Promise<Bool> {
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
            .recover { error -> PromiseKit.Promise<Bool> in
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
    
    // TODO: Load from GraphQL
    /// Loads details based on a SingPass sign in (singapore only!)
    ///
    /// - Parameter code: The code associated with the user in SingPass
    /// - Returns: A promise which, when fulfilled, will contain the user's `MyInfoDetails`.
    public func loadSingpassInfo(code: String) -> PromiseKit.Promise<MyInfoDetails> {
        let myInfoEndpoints: [RegionEndpoint] = [
            .region(code: "sg"),
            .kyc,
            .myInfo,
            .v3,
            .personData,
            .myInfoCode(code: code)
        ]
        
        let path = RootEndpoint.regions.pathByAddingEndpoints(myInfoEndpoints)
        
        return self.loadData(from: path)
            .map { try self.decoder.decode(MyInfoDetails.self, from: $0) }
    }

    // TODO: Load from GraphQL
    /// Loads configuration details of MyInfo sign in (singapore only!)
    ///
    /// - Returns: A promise which, when fulfilled, will contain the user's `MyInfoConfig`.
    public func loadMyInfoConfig() -> PromiseKit.Promise<MyInfoConfig> {
        let myInfoEndpoints: [RegionEndpoint] = [
            .region(code: "sg"),
            .kyc,
            .myInfo,
            .v3,
            .config
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
    public func loadData(from path: String, queryItems: [URLQueryItem]? = nil) -> PromiseKit.Promise<Data> {
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
    public func sendObject<T: Codable>(_ object: T, to path: String, method: HTTPMethod) -> PromiseKit.Promise<(data: Data, response: URLResponse)> {
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
                          method: HTTPMethod) -> PromiseKit.Promise<(data: Data, response: URLResponse)> {
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
    
    private func getToken() -> PromiseKit.Promise<String> {
        return self.tokenProvider.getToken()
            .map { token -> String in
                self.token = token
                return token
        }
    }
}

// MARK: - Pre-flight delegate
extension PrimeAPI: HTTPNetworkTransportPreflightDelegate {
    public func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool {
        return true
    }
    
    public func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest) {
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        
        if let xMode = ProcessInfo.processInfo.environment["HTTP_HEADER_X_MODE"] {
            request.setValue("X-Mode", forHTTPHeaderField: xMode)
        }
    }
}
