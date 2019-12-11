//
//  AppleIdToken.swift
//  ostelco-core
//
//  Created by Prasanth Ullattil on 10/08/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct AppleIdToken: Codable {
    public let authCode: String

    public init(authCode: String) {
        self.authCode = authCode
    }
}

public struct FirebaseCustomTokenModel: Codable {
    public let token: String
}
