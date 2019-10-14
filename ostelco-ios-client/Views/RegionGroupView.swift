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
    
    @EnvironmentObject var store: AppStore
    
    let countrySelected: (Country) -> Void
    
    private func renderSimProfile(_ regionGroup: RegionGroupViewModel, country: Country) -> AnyView {
        
        if store.simProfilesForCountry(country: country).filter({ $0.status == .installed }).isNotEmpty {
            return AnyView(
                ESimCountryView(image: country.image, country: country.nameOrPlaceholder)
            )
        }
        return AnyView(
            ESimCountryView(image: country.image, country: country.nameOrPlaceholder, action: {
                // TODO: Refactor this so isnt dependent on CoverageViewController
                self.countrySelected(country)
            })
        )
    }
    
    private func renderBody() -> AnyView {
        if let regionGroup = store.selectedRegionGroup {
            return AnyView(
                VStack {
                    RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, backgroundColor: regionGroup.backgroundColor.toColor)
                    List(store.allowedCountries(countries: regionGroup.countries).map({ Country($0) }), id: \.countryCode) { country in
                        Group {
                            self.renderSimProfile(regionGroup, country: country)
                        }.frame(maxWidth: .infinity, minHeight: 94.0)
                    }.cornerRadius(28)
                    .padding([.leading, .trailing, .top ], 10)
                }.background(OstelcoColor.lipstick.toColor)
            )
        } else {
            return AnyView(Text("Something went wrong..."))
        }
    }
    var body: some View {
        renderBody()
    }
}
struct RegionView_Previews: PreviewProvider {
    static var previews: some View {
        RegionGroupView(countrySelected: { _ in
        
        })
    }
}
