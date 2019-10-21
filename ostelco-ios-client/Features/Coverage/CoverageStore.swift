//
//  AppStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

final class CoverageStore: ObservableObject {
    @Published var country: Country?
    @Published var regions: [PrimeGQL.RegionDetailsFragment]?
    @Published var countryCodeToRegionCodeMap = [:] as [String:[String]]
    @Published var regionGroups: [RegionGroupViewModel] = []
    
    @Published var selectedRegionGroup: RegionGroupViewModel?
    
    let controller: TabBarViewController
    
    init(controller: TabBarViewController) {
        self.controller = controller
        country = LocationController.shared.currentCountry
        NotificationCenter.default.addObserver(self, selector: #selector(countryChanged(_:)), name: CurrentCountryChanged, object: nil)
        
        loadRegions()
        
        countryCodeToRegionCodeMap = RemoteConfigManager.shared.countryCodeAndRegionCodes.reduce(into: [:], { (result, value) in
            result[value.countryCode] = value.regionCodes
        })
        regionGroups = RemoteConfigManager.shared.regionGroups.map {
            RegionGroupViewModel(
                name: $0.name,
                description: $0.description,
                backgroundColor: $0.backgroundColor,
                isPreview: $0.isPreview,
                countries: $0.countryCodes.map({ Country($0) })
            )
        }
    }
    
    func loadRegions() {
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
    
    func getRegionFromCountry(_ country: Country) -> PrimeGQL.RegionDetailsFragment {
        guard let regionCodes = countryCodeToRegionCodeMap[country.countryCode] else {
            fatalError("If there are no region codes for the given country code, our configuration is wrong.")
        }
        
        // TODO: We could make this logic smarter. This selects the region to use in cases for a country has multiple regions to select from.
        guard let region = regions?.filter({ $0.region.id == regionCodes.first }).first else {
            fatalError("If there are no regions for the given region code, our configuration is wrong.")
        }
        
        return region
    }
    
    func allowedCountries(countries: [Country]) -> [String] {
        return Array(Set(allowedCountries()).intersection(countries.map({ $0.countryCode })))
    }
    
    func startOnboardingForCountry(_ country: Country) {
        let region = getRegionFromCountry(country)
        controller.startOnboardingForRegionInCountry(country, region: region)
    }
    
    func startOnboardingForRegionInCountry(_ country: Country, region: PrimeGQL.RegionDetailsFragment) {
        controller.startOnboardingForRegionInCountry(country, region: region)
    }

}
