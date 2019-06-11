//
//  SimProfileRequest.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public enum ProfileType: String, Codable {
    case iPhone = "iphone"
    case test = "TEST"
}

public struct SimProfileRequest: Codable {
    public let profileType: ProfileType
    
    public init() {
        #if DEBUG
            // Use a test profile when debugging so we don't create a trillion sim cards.
            self.profileType = .test
        #else
            self.profileType = .iPhone
        #endif
    }
    
    public enum CodingKeys: String, CodingKey {
        case profileType
    }
    
    public var asQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(codingKey: CodingKeys.profileType, value: self.profileType.rawValue)
        ]
    }
}
