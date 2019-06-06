//
//  CountryDeterminablePlacemark.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 6/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation

/// A protocol matching the info we need from CLPlacemarks so this info can be mocked.
public protocol CountryDeterminablePlacemark {
    var isoCountryCode: String? { get }
    var country: String? { get }
}

extension CLPlacemark: CountryDeterminablePlacemark {}
