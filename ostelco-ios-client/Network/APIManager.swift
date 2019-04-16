//
//  API.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Siesta

class APIManager: Service {

    static let sharedInstance = APIManager()
    let jsonDecoder = JSONDecoder()
    var authHeader: String? {
        didSet {
            invalidateConfiguration()
            wipeResources()
        }
    }

    var customer: Resource { return resource("/customer") }
    var products: Resource { return resource("/products") }
    var context: Resource { return resource("/context") }
    var regions: Resource { return resource("/regions") }

    fileprivate init() {
        let networking = URLSessionConfiguration.ephemeral
        networking.timeoutIntervalForRequest = 300
        super.init(
            baseURL: Environment().configuration(PlistKey.ServerURL),
            standardTransformers: [.text],
            networking: networking
        )

        configure {
            $0.headers["Content-Type"] = "application/json"
            $0.headers["Authorization"] = self.authHeader
        }

        configureTransformer("/customer", requestMethods: [.get, .post, .put]) {
            try self.jsonDecoder.decode(CustomerModel.self, from: $0.content)
        }

        configureTransformer("/regions/*/kyc/jumio/scans") {
            try self.jsonDecoder.decode(Scan.self, from: $0.content)
        }

        configureTransformer("/regions/sg/kyc/myInfo/*") {
            try self.jsonDecoder.decode(MyInfoDetails.self, from: $0.content)
        }

        configureTransformer("/regions/*/simProfiles", requestMethods: [.get]) {
            try self.jsonDecoder.decode([SimProfile].self, from: $0.content)
        }
        
        configureTransformer("/regions/*/simProfiles", requestMethods: [.post]) {
            try self.jsonDecoder.decode(SimProfile.self, from: $0.content)
        }
        
        self.configure("/reginos/*/simProfiles") {
            $0.expirationTime = 5
        }
        
        configureTransformer("/regions/*") {
            try self.jsonDecoder.decode(RegionResponse.self, from: $0.content)
        }
        
        configureTransformer("/regions") {
            try self.jsonDecoder.decode([RegionResponse].self, from: $0.content)
        }

        configureTransformer("/context") {
            try self.jsonDecoder.decode(Context.self, from: $0.content)
        }
    }
}

extension APIManager {
    
    // TODO: Move to APIHelper together with the below todo
    enum APIError: Swift.Error, LocalizedError {
        case failedToGetRegion
        case failedToParse
        
        var localizedDescription: String {
            switch self {
            case .failedToGetRegion: // TODO: This error is specific to the APIManager, not APIHelper, thus should stay here
                return "Could not find suitable region from region response"
            case .failedToParse:
                return "Something went wrong while parsing the API response"
            }
        }
    }
    
    // TODO: Abstract the parsing logic into APIHelper using RegionResponse as a generic type. And handle the specific logic of returning one region out of a list inside this function. Also Refactor to use PromiseKit
    func getRegionFromRegions(completion: @escaping (RegionResponse?, Error?) -> Void) {
        regions.load()
            .onSuccess { response in
                if let regionResponseArray: [RegionResponse] = response.typedContent(ifNone: []) {
                    if let region = getRegionFromRegionResponseArray(regionResponseArray) {
                        DispatchQueue.main.async {
                            completion(region, nil)
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, APIError.failedToGetRegion)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, APIError.failedToParse)
                    }
                }
            }
            .onFailure { requestError in
                DispatchQueue.main.async {
                    completion(nil, requestError)
                }
            }
    }
}
