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
}
