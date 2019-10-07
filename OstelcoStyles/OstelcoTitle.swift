//
//  OstelcoTitle.swift
//  OstelcoStyles
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

public struct OstelcoTitle: View {
    let label: String
    let image: String?
    let description: String?
    
    public init(label: String, image: String? = nil, description: String? = nil) {
        self.label = label
        self.image = image
        self.description = description
    }
    
    public var body: some View {
        VStack {
            HStack {
                image.map {
                    Image(systemName: $0)
                        .font(.system(size: 24, weight: .bold))
                }
                Text(label)
                    .font(.system(size: 28, weight: .bold))
            }
            Divider()
                .frame(width: 50, height: 3)
                .background(OstelcoColor.oyaBlue.toColor)
            description.map {
                Text($0)
                    .font(.system(size: 18))
                    .foregroundColor(OstelcoColor.text.toColor)
                    .padding(.top, 20)
            }
        }
    }
}

struct OstelcoTitle_Previews: PreviewProvider {
    static var previews: some View {
        OstelcoTitle(label: "Location", image: "location.fill", description: "A paragraph")
    }
}
