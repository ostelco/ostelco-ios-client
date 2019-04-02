//
//  PutProfileError.swift
//  ostelco-ios-client
//
//  Created by mac on 4/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

struct PutProfileError: Codable {
    let errors: [String]
    
    enum CodingKeys: String, CodingKey {
        case errors
    }
}
