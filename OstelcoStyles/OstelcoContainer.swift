//
//  OstelcoContainer.swift
//  OstelcoStyles
//
//  Created by mac on 10/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

public enum OstelcoContainerState {
    case active
    case inactive
}

public struct OstelcoContainer<Content: View>: View {
    var content: () -> Content
    let state: OstelcoContainerState

    public init(state: OstelcoContainerState = .active, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.state = state
    }
    
    private func render() -> some View {
        let root = Group {
            content()
        }
        .frame(maxWidth: .infinity, minHeight: 94.0)
        .background(OstelcoColor.background.toColor)
        
        switch state {
        case .inactive:
            return AnyView(
                root
                .overlay( // TODO: Had to use overlay to be able to draw a rounded border, but the overlay removes the background color set on the root above. Find a way to keep background and rounded border
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(OstelcoColor.containerBorder.toColor, lineWidth: 1)
                )
            )
        case .active:
            return AnyView(root
            .cornerRadius(28)
            .clipped()
            .shadow(color: OstelcoColor.shadow.toColor, radius: 16, x: 0, y:
                6))
            
        }
    }
    
    public var body: some View {
        render()
    }
}

struct OstelcoContainer_Previews: PreviewProvider {
    static var previews: some View {
        OstelcoContainer {
            Spacer()
        }
    }
}
