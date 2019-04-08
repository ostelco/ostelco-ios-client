//
//  Scan.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

struct Scan: Codable {
    let countryCode: String
    let scanId: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case countryCode, scanId, status
    }
}
