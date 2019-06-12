//
//  MockPlacemarks.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core

// Some CLPlacemark subclasses to allow mocking the call to
// reverse geocode so it doesn't time out on CI.
class SingaporePlacemark: CountryDeterminablePlacemark {
    // Merlion statue in Singapore
    static let location = CLLocation(latitude: 1.28554552448,
                                     longitude: 103.852809922)
    
    var isoCountryCode: String? {
        return "SG"
    }
    
    var country: String? {
        return "Singapore"
    }
}

class AmericaPlacemark: CountryDeterminablePlacemark {
    
    // Wrigley Field in Chicago
    static let location = CLLocation(latitude: 41.942329564,
                                     longitude: -87.65333072)

    var isoCountryCode: String? {
        return "US"
    }
    
    var country: String? {
        return "United States"
    }
}

class TuvaluPlacemark: CountryDeterminablePlacemark {
    
    // The Funafuti International Airport
    static let location = CLLocation(latitude: -8.524590,
                                     longitude: 179.195056)
    
    var isoCountryCode: String? {
        return "TV"
    }
    
    var country: String? {
        return "Tuvalu"
    }
}
