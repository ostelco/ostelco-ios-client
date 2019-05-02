//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

enum SimProfileStatus: String, Codable {
    case AVAILABLE_FOR_DOWNLOAD
    case DOWNLOADED
    case INSTALLED
    case ENABLED
}

struct SimProfile: Codable {
    let esimActivationCode: String
    let alias: String
    let iccId: String
    let status: SimProfileStatus
}
