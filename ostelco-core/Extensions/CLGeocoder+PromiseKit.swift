//
//  CLGeocoder+PromiseKit.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import PromiseKit

enum GeocodingError: Error {
    case placemarksWereNil
}

extension CLGeocoder {
    
    /// Wraps the reverse geocode callback in a promise
    ///
    /// - Parameter location: The location to check for.
    /// - Returns: A promise which, when successful, will return the placemarks retrieved.
    func reverseGeocode(location: CLLocation) -> Promise<[CLPlacemark]> {
        return Promise { seal in
            self.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let geocodeError = error {
                    seal.reject(geocodeError)
                    return
                }
                
                guard let places = placemarks else {
                    seal.reject(GeocodingError.placemarksWereNil)
                    return
                }
                
                seal.fulfill(places)
            })
        }
    }
}
