//
//  JSONRequestError.swift
//  ostelco-ios-client
//
//  Created by mac on 4/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

struct JSONRequestError: Codable {
    let errorCode: String
    let httpStatusCode: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case errorCode, httpStatusCode = "status", message
    }
}
