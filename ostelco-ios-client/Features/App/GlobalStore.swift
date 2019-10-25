//
//  GlobalStore.swift
//  ostelco-ios-client
//
//  Created by mac on 10/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

final class GlobalStore: ObservableObject {
    @Published var country: Country?
    @Published var previousCountry: Country?
    @Published var regions: [PrimeGQL.RegionDetailsFragment]?
    @Published var countryCodeToRegionCodeMap = [:] as [String: [String]]
    
    init() {
        
        country = LocationController.shared.currentCountry

        if let countryCode = UserDefaultsWrapper.countryCode {
            previousCountry = Country(countryCode)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(countryChanged(_:)), name: CurrentCountryChanged, object: nil)
        
        loadRegions()
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
        UserDefaultsWrapper.countryCode = country?.countryCode
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
    
    func showCountryChangedMessage() -> Country? {
        if let previousCountry = previousCountry, let country = country {
            
            if previousCountry.countryCode != country.countryCode && simProfilesForCountry(country: country).filter({ $0.status == .installed }).isEmpty
            {
                return country
            }
        }
        return nil
    }
}
