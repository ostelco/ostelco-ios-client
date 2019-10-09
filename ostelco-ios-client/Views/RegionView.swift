//
//  RegionView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import ostelco_core
import OstelcoStyles

struct RegionGroupView: View {
    // TODO: Should be a list of regions
    let countries = ["SE", "HK", "ID", "MY", "NO", "PH", "SG", "TH", "US"].map { Country($0) }
    // TODO: Should be region selected (when above list is turned into a list of regions)
    let countrySelected: (Country) -> Void
    
    var body: some View {
        VStack {
            RegionGroupCardView(label: "Asia", description: "Southeast asia & pacific", backgroundColor: OstelcoColor.lipstick.toColor)
            List(countries, id: \.countryCode) { country in
                Group {
                    ESimCountryView(image: country.image, country: country, action: {
                        // TODO: This is not presenting the onboarding flow for some reason
                        // TODO: Refactor this so isnt dependent on CoverageViewController
                        self.countrySelected(country)
                    })
                }.frame(maxWidth: .infinity, minHeight: 94.0)
            }.cornerRadius(28)
            .padding([.leading, .trailing, .top ], 10)
        }.background(OstelcoColor.lipstick.toColor)
    }
}
struct RegionView_Previews: PreviewProvider {
    static var previews: some View {
        RegionGroupView(countrySelected: { _ in
        
        })
    }
}
