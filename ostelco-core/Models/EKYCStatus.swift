//
//  EKYCStatus.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public enum EKYCStatus: String, Codable, CaseIterable {
    case APPROVED
    case REJECTED
    case PENDING
    
    func getGraphQLModel() -> KycStatus {
        return KycStatus(rawValue: self.rawValue)!
    }
    
    func toCustomerRegionStatus() -> CustomerRegionStatus {
        return CustomerRegionStatus(rawValue: self.rawValue)!
    }
}
