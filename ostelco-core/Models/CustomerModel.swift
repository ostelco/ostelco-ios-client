//
//  CustomerModel.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct CustomerModel: Codable {
    public let id: String
    public let name: String
    public let email: String
    public let analyticsId: String
    public let referralId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "nickname"
        case email = "contactEmail"
        case analyticsId
        case referralId
    }
    
    public func hasSubscription() -> Bool {
        return false
    }
}
