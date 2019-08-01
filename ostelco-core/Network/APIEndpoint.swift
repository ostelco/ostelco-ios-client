//
//  APIEndpoint.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

protocol APIEndpoint {
    var value: String { get }
}

extension APIEndpoint {
    
    func pathByAddingEndpoints(_ endpoints: [APIEndpoint]) -> String {
        let restOfPath = endpoints
            .map { $0.value }
            .joined(separator: "/")
        
        return self.value + "/" + restOfPath
    }
}

public enum RootEndpoint: String, APIEndpoint {
    case applicationToken
    case bundles
    case context
    case customer
    case purchases
    case products
    case profile
    case regions
    case graphql

    var value: String {
        return self.rawValue
    }
}

public enum RegionEndpoint: APIEndpoint {
    case dave
    case jumio
    case kyc
    case myInfo
    case v3
    case personData
    case config
    case myInfoCode(code: String)
    case nric(number: String)
    case region(code: String)
    case profile
    case simProfiles
    case scans
    case iccId(code: String)
    case resendEmail
    
    var value: String {
        switch self {
        case .dave:
            // I can't let you do that,
            return "dave"
        case .jumio:
            return "jumio"
        case .kyc:
            return "kyc"
        case .myInfo:
            return "myInfo"
        case .myInfoCode(let code):
            return code
        case .v3:
            return "v3"
        case .config:
            return "config"
        case .personData:
            return "personData"
        case .nric(let number):
            return number
        case .region(let code):
            return code.lowercased()
        case .profile:
            return "profile"
        case .simProfiles:
            return "simProfiles"
        case .scans:
            return "scans"
        case .iccId(let code):
            return code
        case .resendEmail:
            return "resendEmail"
        }
    }
}

public enum ProductEndpoint: APIEndpoint {
    case sku(_ sku: String)
    case purchase
    
    var value: String {
        switch self {
        case .sku(let sku):
            return sku
        case .purchase:
            return "purchase"
        }
    }
}

public enum CustomerEndpoint: APIEndpoint {
    case stripeEphemeralKey

    var value: String {
        switch self {
        case .stripeEphemeralKey:
            return "stripe-ephemeral-key"
        }
    }
}
