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
        // TODO: Make this code a little more readable...
        let regionCodes = store.countryCodeToRegionCodeMap[country.countryCode]!
        // For the region codes mapped to country code in countryCodeToRegionCodeMap, if any of the regions with given region code contains any installed sim profile, mark the country as installed 
        if store.regions!.filter({ regionCodes.contains($0.region.id) }).filter({ $0.simProfiles != nil }).map({ $0.simProfiles! }).reduce([], +).filter({ $0.fragments.simProfileFields.status == .installed }).isNotEmpty {
            return AnyView(
                ESimCountryView(image: country.image, country: country.nameOrPlaceholder)
            )
        }
        return AnyView(
            ESimCountryView(image: country.image, country: country.nameOrPlaceholder, action: {
                // TODO: This is not presenting the onboarding flow for some reason
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
                    List(regionGroup.countries, id: \.countryCode) { country in
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
