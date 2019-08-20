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
    /// Singleton instance. Set up as a var for testing.
    public static var shared = LocationController()
    
    public var currentCountry: Country?
    public var locationProblem: LocationProblem?
    
    /// Are location services currently enabled?
    open var locationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// A callback to listen for when authorization status has changed.
    public var authChangeCallback: ((CLAuthorizationStatus) -> Void)?

    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// The user's current authorization status with the system.
    open var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    open func requestAuthorization() {
        return self.locationManager.requestAlwaysAuthorization()
    }
    
    open func reverseGeocode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if let geocodeError = error {
                debugPrint(geocodeError)
                return
            }
            
            if let code = placemarks?.first?.isoCountryCode {
                self.currentCountry = Country(code)
                print("Current country: \(self.currentCountry?.name ?? "none")")
            }
        })
    }
    
    public func checkInCorrectCountry(_ country: Country) -> Bool {
        if currentCountry == country {
            return true
        } else {
            return false
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        debugPrint("- LocationController did fail with error: \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            // This should get called again with a more accurate location
            return
        }
        
        reverseGeocode(location: first)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        assert(Thread.isMainThread)
        DispatchQueue.main.async {
            self.authChangeCallback?(status)
        }
    }
}
