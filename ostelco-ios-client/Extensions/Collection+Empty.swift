//
//  Collection+Empty.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public extension Collection {
    
    /// Inverts the `isEmpty` check. Mostly for readability in `guard` statements.
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
