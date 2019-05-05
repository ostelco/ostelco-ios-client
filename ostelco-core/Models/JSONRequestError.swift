//
//  JSONRequestError.swift
//  ostelco-ios-client
//
//  Created by mac on 4/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct JSONRequestError: Codable {
    public let errorCode: String
    public let httpStatusCode: Int
    public let message: String
    
    enum CodingKeys: String, CodingKey {
        case errorCode
        case httpStatusCode = "status"
        case message
    }
}
