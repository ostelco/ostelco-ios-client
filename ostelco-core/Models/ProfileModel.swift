//
//  ProfileModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct ProfileModel: Codable {
    let name: String
    let email: String
    let address: String
    let city: String
    let country: String
    let postCode: String
    let referralId: String

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case address
        case city
        case country
        case postCode
        case referralId
    }
}
