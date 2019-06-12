//
//  MockLocationController.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core
import PromiseKit

class MockLocationController: LocationController {
    
    enum Error: Swift.Error {
        case noMockLocation
        case invalidLocationToCheck
    }
    
    var shouldAuthorize = true
    var mockAreLocationServicesEnabled = true
    var mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
    var mockLocation: CLLocation?
    
    override var locationServicesEnabled: Bool {
        return self.mockAreLocationServicesEnabled
    }
    
    override var authorizationStatus: CLAuthorizationStatus {
        return self.mockAuthorizationStatus
    }
    
    override func requestAuthorization() {
        if self.shouldAuthorize {
            self.mockAuthorizationStatus = .authorizedAlways
        } else {
            self.mockAuthorizationStatus = .denied
        }
    }
    
    override func requestLocation() -> Promise<CLLocation> {
        guard let location = self.mockLocation else {
            return Promise(error: Error.noMockLocation)
        }
        
        return .value(location)
    }
    
    override func reverseGeocode(location: CLLocation) -> Promise<[CountryDeterminablePlacemark]> {
        switch location.coordinate.longitude {
        case 103.851...103.853:
            let singapore = SingaporePlacemark()
            return .value([singapore])
        case 179.195...179.196:
            let tuvalu = TuvaluPlacemark()
            return .value([tuvalu])
        case (-87.654)...(-87.652):
            let america = AmericaPlacemark()
            return .value([america])
        default:
            return Promise(error: Error.invalidLocationToCheck)
        }
    }
}
