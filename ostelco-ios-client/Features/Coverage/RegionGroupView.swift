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
    
    @EnvironmentObject var store: CoverageStore
    
    let regionGroup: RegionGroupViewModel
    let countrySelected: (Country) -> Void
    
    private func renderSimProfile(_ regionGroup: RegionGroupViewModel, country: Country) -> AnyView {
        
        if store.simProfilesForCountry(country: country).filter({ $0.status == .installed }).isNotEmpty {
            return AnyView(
                ESimCountryView(image: country.image, country: country.nameOrPlaceholder, icon: "checkmark")
            )
        }
        return AnyView(
            ESimCountryView(image: country.image, country: country.nameOrPlaceholder, action: {
                self.countrySelected(country)
            })
        )
    }
    
    var body: some View {
        ZStack {
            regionGroup.backgroundColor.toColor
            VStack {
                RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, backgroundColor: regionGroup.backgroundColor.toColor)
                List(store.allowedCountries(countries: regionGroup.countries).map({ Country($0) }), id: \.countryCode) { country in
                    Group {
                        self.renderSimProfile(self.regionGroup, country: country)
                    }.frame(maxWidth: .infinity, minHeight: 94.0)
                }.cornerRadius(28)
                .padding([.leading, .trailing, .top ], 10)
                .padding(.bottom, 30)
            }.padding(.top, 25)
        }.edgesIgnoringSafeArea(.top)
        .onAppear {
            OstelcoAnalytics.setScreenName(name: "RegionGroupView")
        }
    }
}
struct RegionView_Previews: PreviewProvider {
    static var previews: some View {
        RegionGroupView(regionGroup: RegionGroupViewModel(name: "xxx", description: "xxx", backgroundColor: .lipstick, isPreview: false, countries: []), countrySelected: { _ in
        
        })
    }
}
