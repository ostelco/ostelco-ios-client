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

struct RegionView: View {
    var body: some View {
        Text("Test")
    }
}

struct CoverageView: View {
    
    @ObservedObject var store = AppStore()
    let controller: CoverageViewController
    let countries = ["SE", "HK", "IN", "MY", "NO", "PH", "SG", "TH", "US"].map { Country($0) }
    @State private var showModal: Bool = false
    
    init(controller: CoverageViewController) {
        self.controller = controller
        UINavigationBar.appearance().backgroundColor = OstelcoColor.background.toUIColor
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    OstelcoTitle(label: "Location", image: "location.fill")
                    
                    store.country.map { country in
                        
                        Group {
                            OstelcoContainer {
                                ESimCountryView(image: country.image, country: country, heading: "BASED ON LOCATION", action: {
                                    // TODO: Refactor this to not be dependent on CoverageViewController
                                    self.controller.startOnboardingForCountry(country)
                                })
                            }
                            
                            OstelcoContainer(state: .inactive) {
                                ESimCountryView(image: country.image, country: country, heading: "BASED ON LOCATION")
                            }
                        }
                    }
                    
                    OstelcoTitle(label: "All Destinations")
                    
                    Button(action: {
                        debugPrint(self.showModal)
                        self.showModal = true
                    }) {
                        RegionCardView(label: "Asia", description: "Southeast asia & pacific", backgroundColor: OstelcoColor.lipstick.toColor)
                    }.cornerRadius(28)
                    .clipped()
                    .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
                    RegionCardView(label: "The Americas", description: "Latin & north america", centerText: "Coming Soon", backgroundColor: OstelcoColor.azul.toColor)
                    
                    ForEach(countries, id: \.countryCode ) { country in
                        OstelcoContainer {
                            ESimCountryView(image: country.image, country: country, action: {
                                // TODO: Refactor this so isnt dependent on CoverageViewController
                                self.controller.startOnboardingForCountry(country)
                            })
                        }
                    }
                }.padding()
            }
        }.sheet(isPresented: $showModal) {
            RegionView()
        }
    }
}

struct CoverageView_Previews: PreviewProvider {
    static var previews: some View {
        CoverageView(controller: CoverageViewController())
    }
}
