//
//  PushToken.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct PushToken: Codable {
    public let token: String
    public let tokenType: String
    public let applicationID: String
    
    public init(token: String,
                tokenType: String = "FCM",
                applicationID: String) {
        self.token = token
        self.tokenType = tokenType
        self.applicationID = applicationID
    }
}
