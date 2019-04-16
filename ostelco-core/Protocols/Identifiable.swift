//
//  Identifiable.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

/// A protocol to represent types which should have an identifier
public protocol Identifiable {
 
    /// A string representing this type
    static var identifier: String { get }
}

// MARK: - Default implementation

public extension Identifiable {
    
    static var identifier: String {
        // Defaults to the String name of the type itself.
        return String(describing: self)
    }
}
