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
            Image(uiImage: UIImage.ostelco_illustration)
        }.frame(maxWidth: .infinity)
        .padding(.top, 70)
        .background(backgroundColor)
        .cornerRadius(28)
        .clipped()
        .shadow(color: OstelcoColor.regionShadow.toColor, radius: 16, x: 0, y: 6)
        .overlay(
            HStack { // Are there any other ways to create a view that fills up its parent?
                VStack {
                    Spacer()
                }
                Spacer()
            }
            .background(centerText != nil ? Color(red: 0, green: 0, blue: 0, opacity: 0.6) : Color(red: 0, green: 0, blue: 0, opacity: 0)) // Is there a way to only render this component if centerText != nil instead of rendering the component with a transparent background
            .cornerRadius(28)
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
                    RegionView(label: "Asia", description: "Southeast asia & pacific", backgroundColor: OstelcoColor.lipstick.toColor)
                    RegionView(label: "The Americas", description: "Latin & north america", centerText: "Coming Soon", backgroundColor: OstelcoColor.azul.toColor)
                    
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
