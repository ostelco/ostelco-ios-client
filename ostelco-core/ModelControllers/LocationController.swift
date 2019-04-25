//
//  LocationController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import Foundation
import PromiseKit

open class LocationController: NSObject, CLLocationManagerDelegate {
    
    public enum Error: Swift.Error {
        case noPlacemarksReturned
        case couldntGetCountryCode(from: CLPlacemark)
        case locationProblem(problem: LocationProblem)
    }
    
    /// Singleton instance. Set up as a var for testing.
    public static var shared = LocationController()
    
    /// Is the location controller currently updating the user's location?
    public private(set) var isUpdating = false
    
    /// Are location services currently enabled?
    public var locationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// A callback to listen for when authorization status has changed.
    public var authChangeCallback: ((CLAuthorizationStatus) -> Void)?

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        return manager
    }()
    
    private var locationSeal: Resolver<CLLocation>?
    
    /// The user's current authorization status with the system.
    public var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func requestAuthorization() {
        return self.locationManager.requestAlwaysAuthorization()
    }
    
    public func requestLocation() -> Promise<CLLocation> {
        return Promise { seal in
            self.locationManager.requestLocation()
            self.locationSeal = seal
        }
    }
    
    public func checkInCorrectCountry(_ country: Country) -> Promise<Void> {
        return self.requestLocation()
            .then { CLGeocoder().reverseGeocode(location: $0) }
            .done { placemarks in
                guard let placemark = placemarks.first else {
                    throw Error.noPlacemarksReturned
                }
                    
                guard let isoCountryCode = placemark.isoCountryCode else {
                    throw Error.couldntGetCountryCode(from: placemark)
                }
                
                guard country.countryCode == isoCountryCode else {
                    let expected = country.name ?? "(Unknown)"
                    let actual = placemark.country ?? "(Unknown)"
                    let problem = LocationProblem.authorizedButWrongCountry(expected: expected, actual: actual)
                    throw Error.locationProblem(problem: problem)
                }
                    
                // If we got here, we're good!
            }
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        self.isUpdating = false
    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        self.isUpdating = true
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        debugPrint("- LocationController did fail with error: \(error)")
        if let locationSeal = self.locationSeal {
            locationSeal.reject(error)
            self.locationSeal = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            // This should get called again with a more accurate location
            return
        }
        
        if let locationSeal = self.locationSeal {
            locationSeal.fulfill(first)
            self.locationSeal = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authChangeCallback?(status)
        }
    }
}