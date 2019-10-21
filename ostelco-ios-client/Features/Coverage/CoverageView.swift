//
//  CoverageView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import UIKit
import OstelcoStyles
import ostelco_core

enum RegionGroupBackgroundColor: String, Codable {
    
    case lipstick
    case azul
    case yellow
    
    var toOstelcoColor: OstelcoColor {
        switch self {
        case .lipstick:
            return OstelcoColor.lipstick
        case .azul:
            return OstelcoColor.azul
        case .yellow:
            return OstelcoColor.statusOkay
        }
    }
    var toColor: Color {
        return toOstelcoColor.toColor
    }
    
    var toUIColor: UIColor {
        return toOstelcoColor.toUIColor
    }
}

struct RegionGroupViewModel: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let backgroundColor: RegionGroupBackgroundColor
    let isPreview: Bool
    let countries: [Country]
}

struct CoverageView: View {
    
    @EnvironmentObject var store: CoverageStore
    @State private var selectedRegionGroup: RegionGroupViewModel? = nil
    @State private var showModal: Bool = false
        
    private func renderRegionGroup(_ regionGroup: RegionGroupViewModel) -> AnyView {
        if regionGroup.isPreview {
           return AnyView(
            RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, centerText: regionGroup.isPreview ? "Coming Soon" : nil, backgroundColor: regionGroup.backgroundColor.toColor)
               .cornerRadius(28)
               .clipped()
               .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
           )
        } else {
            return AnyView(
                NavigationLink(destination: RegionGroupView(regionGroup: regionGroup ,countrySelected: { country in
                   // TODO: Change RegionView presentation from modal to either animation or navigation, then we can remove the below hack
                    self.store.startOnboardingForCountry(country)
            }).environmentObject(self.store)) {
                RegionGroupCardView(label: regionGroup.name, description: regionGroup.description, backgroundColor: regionGroup.backgroundColor.toColor)
               }.cornerRadius(28)
               .clipped()
               .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
           )
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    OstelcoTitle(label: "Location", image: "location.fill")
                    
                    RegionListByLocation()
                    
                    OstelcoTitle(label: "All Destinations")
                
                    // TODO: Cleanup
                    ForEach(store.regionGroups.filter({ $0.isPreview || store.regions != nil && Set(store.allowedCountries()).intersection(Set($0.countries.map({ $0.countryCode }))).isNotEmpty }), id: \.id) { self.renderRegionGroup($0) }
                    
                }.padding()
            }.navigationBarTitle("", displayMode: .inline)
        }.onAppear {
            self.store.loadRegions()
        }
    }
}

struct CoverageView_Previews: PreviewProvider {
    static var previews: some View {
        CoverageView()
    }
}
