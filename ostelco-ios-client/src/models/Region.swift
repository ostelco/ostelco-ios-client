//
//  Region.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

struct Region: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
}

struct RegionResponse: Codable {
    let region: Region
    let status: String
    let simProfiles: [SimProfile]?
    
    enum CodingKeys: String, CodingKey {
        case region, status, simProfiles
    }
}
