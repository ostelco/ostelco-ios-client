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
}
