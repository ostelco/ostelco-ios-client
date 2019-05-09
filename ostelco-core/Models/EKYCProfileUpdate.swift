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
}
