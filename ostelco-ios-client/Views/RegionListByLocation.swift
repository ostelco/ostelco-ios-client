//
//  RegionListByLocation.swift
//  ostelco-ios-client
//
//  Created by mac on 10/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles
import ostelco_core

struct RegionListByLocation: View {
    
    @EnvironmentObject var store: AppStore
    let controller: CoverageViewController
    
    var body: some View {
        renderListOrUnavailable()
    }
    
    private func renderSimProfile(_ regionDetails: PrimeGQL.RegionDetailsFragment, country: Country) -> AnyView {
        
        if (regionDetails.simProfiles ?? []).contains(where: { $0.fragments.simProfileFields.status == .installed }) {
            return AnyView(
                OstelcoContainer(state: .inactive) {
                    ESimCountryView(image: country.image, country: regionDetails.region.name, heading: "BASED ON LOCATION")
                }
            )
        }
        return AnyView(
            OstelcoContainer {
                ESimCountryView(image: country.image, country: regionDetails.region.name, heading: "BASED ON LOCATION", action: {
                    // TODO: Refactor this to not be dependent on CoverageViewController
                    self.controller.startOnboardingForCountry(country)
                })
            }
        )
    }
    
    private func renderListOrUnavailable() -> AnyView {
        
        if let country = store.country {
            // regions can be nil if its not loaded or we failed to fetch them from server, we present these errors as if there are no available regions.
            if let regionCodes = store.countryCodeToRegionCodeMap[country.countryCode], let regionDetailsList = store.regions?.filter({ regionCodes.contains($0.region.id.lowercased()) }), regionDetailsList.isNotEmpty {
                
                return AnyView(
                    Group {
                        ForEach(regionDetailsList, id: \.region.id) { regionDetails in
                            self.renderSimProfile(regionDetails, country: country)
                        }
                    }
                )
            } else {
                return AnyView(
                    Text("Unfortunately OYA is currently not available in\n\(country.nameOrPlaceholder)")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                )
            }
        } else {
            return AnyView(
                Text("We are having troubles finding your location.")
            )
        }
    }
}

struct RegionListByLocation_Previews: PreviewProvider {
    static var previews: some View {
        RegionListByLocation(controller: CoverageViewController())
    }
}
