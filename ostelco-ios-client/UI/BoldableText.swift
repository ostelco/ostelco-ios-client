//
//  BoldableText.swift
//  OstelcoStyles
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct BoldableText {
    public let fullText: String
    public let boldedPortion: String?
    
    public init(fullText: String,
                boldedPortion: String?) {
        self.fullText = fullText
        self.boldedPortion = boldedPortion
    }
}
