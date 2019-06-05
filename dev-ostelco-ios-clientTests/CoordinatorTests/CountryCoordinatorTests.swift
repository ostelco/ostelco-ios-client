//
//  CountryCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core
@testable import Oya_Development_app
import XCTest

class CountryCoordinatorTests: XCTestCase {
    
    private lazy var testLocationController = MockLocationController()
    
    private lazy var testCoordinator = CountryCoordinator(navigationController: UINavigationController(), locationController: self.testLocationController)
    
    private lazy var singapore = Country("sg")
    private lazy var america = Country("us")
    
    // Merlion statue in Singapore
    private lazy var singaporeLocation = CLLocation(latitude: 1.28554552448,
                                                    longitude: 103.852809922)
    
    // Wrigley Field in Chicago
    private lazy var americaLocation = CLLocation(latitude: 41.942329564,
                                                  longitude: -87.65333072)
    
    func testHasntSeenLandingKicksToLanding() {
        guard let destination = self.testCoordinator.determineDestination().awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .landing)
    }
    
    func testHasSeenLandingButHasntSelectedCountryKicksToSelectCountry() {
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .chooseCountry)
    }
    
    func testHasSelectedCountryButLocationPermissionNotDeterminedKicksToAllowLocation() {
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .allowLocation)
    }
    
    func testHasSelectedCountryButLocationDisabledAtSystemLevelKicksToLocationProblem() {
        self.testLocationController.mockAreLocationServicesEnabled = false
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .locationProblem(.disabledInSettings))
    }
    
    func testHasSelectedCountryButLocationPermissionDeniedKicksToLocationProblem() {
        self.testLocationController.mockAuthorizationStatus = .denied
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .locationProblem(.deniedByUser))
    }
    
    func testHasSelectedCountryButLocationPermissionRestrictedKicksToLocationProblem() {
        self.testLocationController.mockAuthorizationStatus = .restricted
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(destination, .locationProblem(.restrictedByParentalControls))
    }
    
    func testHasSelectedCountryAndLocationWhenInUseWithCorrectCountryKicksToCompleted() {
        self.testLocationController.mockAuthorizationStatus = .authorizedWhenInUse
        self.testLocationController.mockLocation = self.singaporeLocation
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        XCTAssertEqual(destination, .countryComplete(country: self.singapore))
    }
    
    func testHasSelectedCountryAndLocationWhenInUseWithIncorrectCountryKicksToLocationProblem() {
        self.testLocationController.mockAuthorizationStatus = .authorizedWhenInUse
        self.testLocationController.mockLocation = self.americaLocation
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: self.singapore.nameOrPlaceholder, actual: self.america.nameOrPlaceholder)
        XCTAssertEqual(destination, .locationProblem(wrongCountry))
    }
    
    func testHasSelectedCountryAndLocationAlwaysWithCorrectCountryKicksToCompleted() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = self.americaLocation
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        XCTAssertEqual(destination, .countryComplete(country: self.america))
    }
    
    func testHasSelectedCountryAndLocationAlwaysWithIncorrectCountry() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = self.singaporeLocation
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: self.america.nameOrPlaceholder, actual: self.singapore.nameOrPlaceholder)
        XCTAssertEqual(destination, .locationProblem(wrongCountry))
    }
    
    func testDebugRoutingAlwaysThinksWereInSingapore() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = self.americaLocation
        guard let wrongLocationDestination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        XCTAssertEqual(wrongLocationDestination, .countryComplete(country: self.singapore))
        
        self.testLocationController.mockLocation = self.americaLocation
        guard let correctLocationDestination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: "Singapore", actual: self.america.nameOrPlaceholder)
        XCTAssertEqual(correctLocationDestination, .locationProblem(wrongCountry))
    }
}
