//
//  EKYCStatus.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public enum EKYCStatus: String, Codable {
    case APPROVED
    case REJECTED
    case PENDING
}
