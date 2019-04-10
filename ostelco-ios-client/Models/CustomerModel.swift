//
//  CustomerModel.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

struct CustomerModel: Codable {
    let id: String
    let name: String
    let email: String
    let analyticsId: String
    let referralId: String

    enum CodingKeys: String, CodingKey {
        case id, name="nickname", email="contactEmail", analyticsId, referralId
    }

    func hasSubscription() -> Bool {
        return false
    }
}