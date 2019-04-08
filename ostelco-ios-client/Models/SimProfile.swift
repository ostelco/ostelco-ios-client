//
//  SimProfile.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

enum SimProfileStatus: String, Codable {
    case AVAILABLE_FOR_DOWNLOAD, DOWNLOADED, INSTALLED, ENABLED
}

struct SimProfile: Codable {
    let eSimActivationCode: String
    let alias: String
    let iccId: String
    let status: SimProfileStatus
}
