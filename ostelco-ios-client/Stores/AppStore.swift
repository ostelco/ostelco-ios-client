//
//  AppStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

final class AppStore: ObservableObject {
    @Published var country: Country?
    @Published var regions: [PrimeGQL.RegionDetailsFragment]?
    @Published var countryCodeToRegionCodeMap = [
        "SG": ["sg"],
        "NO": ["no"],
        "US": ["us"],
        "MY": ["my"]
    ]
    
    @Published var regionGroups = [
        RegionGroupViewModel(
            name: "Asia",
            description: "Southeast asia & pacific",
            backgroundColor: .lipstick,
            isPreview: false,
            countries: ["SG", "MY"].map({ Country($0) })
        ),
        RegionGroupViewModel(
            name: "The Americas",
            description: "Latin & north america",
            backgroundColor: .azul,
            isPreview: true,
            countries: [] as [Country]
        )
    ]
    
    @Published var selectedRegionGroup: RegionGroupViewModel?
    
    init() {
        // TODO: Feels like we can refactor this into something simpler
        country = LocationController.shared.currentCountry
        NotificationCenter.default.addObserver(self, selector: #selector(countryChanged(_:)), name: CurrentCountryChanged, object: nil)
        
        APIManager.shared.primeAPI.loadRegions()
            .done { self.regions = $0 }.cauterize()
    }
    
    @objc func countryChanged(_ notification: NSNotification) {
        guard let controller = notification.object as? LocationController else {
            fatalError("Something other than the location controller is posting this notification!")
        }
        country = controller.currentCountry
    }
    
    func allowedCountries() -> [String] {
        if let regionDetailslist = regions {
            let regionCodes = Set(
                regionDetailslist.map({ $0.region.id })
            )
            
            let allowedCountryCodes = Array(
                countryCodeToRegionCodeMap
                    .filter({ (key, value) in Set(value).intersection(regionCodes).isNotEmpty })
                    .keys
                )
            
            return allowedCountryCodes
        }
        
        return []
    }
    
    func simProfilesForCountry(country: Country) -> [PrimeGQL.SimProfileFields] {
        if let regionDetailsList = regions, let regionCodes = countryCodeToRegionCodeMap[country.countryCode] {
            return regionDetailsList
                .filter({ regionCodes.contains($0.region.id) })
                .filter({ $0.simProfiles != nil })
                .map({ $0.simProfiles!.map({ $0.fragments.simProfileFields }) })
                .reduce([], +)
        }
        return []
    }
    
    func allowedCountries(countries: [Country]) -> [String] {
        return Array(Set(allowedCountries()).intersection(countries.map({ $0.countryCode })))
    }
}
