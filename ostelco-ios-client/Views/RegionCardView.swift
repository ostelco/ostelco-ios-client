//
//  RegionCardView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

struct RegionCardView: View {
    let label: String
    let description: String
    let centerText: String?
    let backgroundColor: Color
    
    init(label: String, description: String, centerText: String? = nil, backgroundColor: Color) {
        self.label = label
        self.description = description
        self.centerText = centerText
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Group {
            Image(uiImage: UIImage.ostelco_illustration).renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
        }.frame(maxWidth: .infinity)
        .padding(.top, 70)
        .padding(.bottom, 20)
        .background(backgroundColor)
        .overlay(
            HStack { // Are there any other ways to create a view that fills up its parent?
                VStack {
                    Spacer()
                }
                Spacer()
            }
            
            .background(centerText != nil ? Color(red: 0, green: 0, blue: 0, opacity: 0.6) : Color(red: 0, green: 0, blue: 0, opacity: 0)) // Is there a way to only render this component if centerText != nil instead of rendering the component with a transparent background
        )
        .overlay(
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(description.uppercased())
                        .font(.system(size: 13))
                        .foregroundColor(Color.white)
                        .frame(height: 27)
                        .opacity(0.75)
                        .fixedSize()
                        Text(label)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.white)
                        .fixedSize()
                        Spacer()
                    }
                    Spacer()
                }.padding(20)
                centerText.map {
                    Text($0)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.white)
                }
            }
        )
    }
}

struct RegionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RegionCardView(label: "Asia", description: "Southeast asia & pacific", backgroundColor: OstelcoColor.lipstick.toColor)
    }
}
