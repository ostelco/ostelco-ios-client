//
//  JWT+EmailClaim.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import JWTDecode

extension JWT {
    var email: String? {
        return claim(name: "https://ostelco/email").string
    }
}
