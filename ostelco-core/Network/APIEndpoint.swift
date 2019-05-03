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
    case bundles
    case context
    case customer
    case purchases
    case products
    case profile
    case regions
    
    var value: String {
        return self.rawValue
    }
}

public enum RegionEndpoint: APIEndpoint {
    case dave
    case jumio
    case kyc
    case nric(number: String)
    case region(code: String)
    case profile
    case simProfiles
    case scans
    
    var value: String {
        switch self {
        case .dave:
            // I can't let you do that,
            return "dave"
        case .jumio:
            return "jumio"
        case .nric(let number):
            return number
        case .kyc:
            return "kyc"
        case .region(let code):
            return code
        case .profile:
            return "profile"
        case .simProfiles:
            return "simProfiles"
        case .scans:
            return "scans"
        }
    }
}
