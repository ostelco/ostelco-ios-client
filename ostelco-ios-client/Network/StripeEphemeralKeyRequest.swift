//
//  StripeEphemeralKeyRequest.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct StripeEphemeralKeyRequest: Codable {
    public let apiVersion: String
    
    public init(apiVersion: String) {
        self.apiVersion = apiVersion
    }
    
    public enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
    }
    
    public var asQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(codingKey: CodingKeys.apiVersion, value: self.apiVersion)
        ]
    }
}
