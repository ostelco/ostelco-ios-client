//
//  ServerError.swift
//  ostelco-ios-client
//
//  Created by mac on 4/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct ServerError: Codable {
    public let errors: [String]
}
