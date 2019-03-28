//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

struct SimProfile: Codable {
    let activationCode: String
    let alias: String
    let iccId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case activationCode, alias, iccId, status
    }
}
