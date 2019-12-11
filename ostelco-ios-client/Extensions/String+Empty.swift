//
//  String+Empty.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 6/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == String {
    
    var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var hasTextOtherThanWhitespace: Bool {
        switch self {
        case .none:
            return false
        case .some(let wrapped):
            return wrapped.hasTextOtherThanWhitespace
        }
    }
}

public extension String {
    
    var hasTextOtherThanWhitespace: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmed.isNotEmpty
    }
}
