//
//  OstelcoText.swift
//  OstelcoStyles
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

public struct OstelcoText: View {
    let label: String
    
    public init(label: String) {
        self.label = label
    }
    
    public var body: some View {
        Text(label)
        .font(.system(size: 17))
        .foregroundColor(OstelcoColor.text.toColor)
    }
}
struct OstelcoText_Previews: PreviewProvider {
    static var previews: some View {
        OstelcoText(label: "Hello World!")
    }
}
