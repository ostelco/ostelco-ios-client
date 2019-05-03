//
//  String+Static.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public extension String {
    
    /// Initializer which is inexplicably not in the stdlib
    ///
    /// - Parameter staticString: The static string to use to create a string
    init(staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
