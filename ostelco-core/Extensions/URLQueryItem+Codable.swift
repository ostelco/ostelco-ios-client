//
//  URLQueryItem+Codable.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public extension URLQueryItem {
    
    /// Allows a `Codable` item's `CodingKey` to be passed in instead of a raw string as the key
    ///
    /// - Parameters:
    ///   - codingKey: The coding key to use
    ///   - value: The value to use
    init(codingKey: CodingKey, value: String) {
        self.init(name: codingKey.stringValue, value: value)
    }
}
