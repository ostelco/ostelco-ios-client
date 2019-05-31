//
//  Scan.swift
//  ostelco-ios-client
//
//  Created by mac on 3/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

public struct Scan: Codable {
    public let countryCode: String
    public let scanId: String
    public let status: EKYCStatus
}
