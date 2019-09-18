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
    public let phoneNumber: String
    
    public init(floor: String,
                unit: String,
                block: String,
                building: String,
                street: String,
                postcode: String,
                phone: String = "12345678") {
        self.phoneNumber = phone
        self.address = "\(floor);;;\(unit);;;\(block);;;\(building);;;\(street);;;\(postcode)"
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
