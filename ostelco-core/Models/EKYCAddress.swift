//
//  EKYCAddress.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct EKYCAddress: Codable {
    public let address: String
    
    public init(floor: String,
                unit: String,
                block: String,
                building: String,
                street: String,
                postcode: String) {
        self.address = "\(floor);;;\(unit);;;\(block);;;\(building);;;\(street);;;\(postcode)"
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
