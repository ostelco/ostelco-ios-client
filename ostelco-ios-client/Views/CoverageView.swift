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

struct CoverageView: View {
    
    @ObservedObject var store = AppStore()
    let controller: CoverageViewController
    let countries = ["SE", "HK", "IN", "MY", "NO", "PH", "SG", "TH", "US"].map { Country($0) }
    
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
        }
    }
}

struct CoverageView_Previews: PreviewProvider {
    static var previews: some View {
        CoverageView(controller: CoverageViewController())
    }
}
