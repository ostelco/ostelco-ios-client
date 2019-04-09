//
//  BundleModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

struct BundleModel: Codable {
    let id: String
    let balance: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case balance
    }
}
