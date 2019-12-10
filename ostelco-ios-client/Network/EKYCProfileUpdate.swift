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
    
    public init?(myInfoDetails: MyInfoDetails) {
        self.address = myInfoDetails.address.formattedAddress
    }
    
    public init(address: String) {
        self.address = address
    }
    
    public enum CodingKeys: String, CodingKey {
        case address
    }
    
    public var asQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(codingKey: CodingKeys.address, value: self.address),
        ]
    }
}
