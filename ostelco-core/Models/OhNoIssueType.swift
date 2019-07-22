//
//  OhNoIssueType.swift
//  ostelco-core
//
//  Created by mac on 7/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

public enum OhNoIssueType: Equatable {
    case generic(code: String?)
    case ekycRejected
    case myInfoFailed
    case noInternet
    case paymentFailedGeneric
    case paymentFailedCardDeclined
    case serverUnreachable
}
