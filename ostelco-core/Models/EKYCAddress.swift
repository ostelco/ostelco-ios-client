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
    
    public init(street: String,
                unit: String,
                city: String,
                postcode: String,
                country: String,
                phone: String = "12345678") {
        self.phoneNumber = phone
        self.address = "\(street);;;\(unit);;;\(city);;;\(postcode);;;\(country)"
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
