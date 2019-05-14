//
//  EKYCProfileUpdate.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct EKYCProfileUpdate: Codable {
    public let address: String
    public let phoneNumber: String
    
    public init(address: String,
                phoneNumber: String) {
        self.address = address
        self.phoneNumber = phoneNumber
    }
    
    public enum CodingKeys: String, CodingKey {
        case address
        case phoneNumber
    }
    
    public var asQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(codingKey: CodingKeys.address, value: self.address),
            URLQueryItem(codingKey: CodingKeys.phoneNumber, value: self.phoneNumber)
        ]
    }
}
