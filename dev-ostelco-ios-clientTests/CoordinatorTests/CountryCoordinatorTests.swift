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
    private lazy var tuvalu = Country("tv")
    
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
        self.testLocationController.mockLocation = SingaporePlacemark.location
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        XCTAssertEqual(destination, .countryComplete(country: self.singapore))
    }
    
    func testHasSelectedCountryAndLocationWhenInUseWithIncorrectCountryKicksToLocationProblem() {
        self.testLocationController.mockAuthorizationStatus = .authorizedWhenInUse
        self.testLocationController.mockLocation = AmericaPlacemark.location
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: self.singapore.nameOrPlaceholder, actual: self.america.nameOrPlaceholder)
        XCTAssertEqual(destination, .locationProblem(wrongCountry))
    }
    
    func testHasSelectedCountryAndLocationAlwaysWithCorrectCountryKicksToCompleted() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = AmericaPlacemark.location
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        XCTAssertEqual(destination, .countryComplete(country: self.america))
    }
    
    func testHasSelectedCountryAndLocationAlwaysWithIncorrectCountry() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = SingaporePlacemark.location
        guard let destination = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america, allowDebugRouting: false).awaitResult(in: self, timeout: 30) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: self.america.nameOrPlaceholder, actual: self.singapore.nameOrPlaceholder)
        XCTAssertEqual(destination, .locationProblem(wrongCountry))
    }
    
    func testDebugRoutingAlwaysThinksWereInSingaporeOrTheUS() {
        self.testLocationController.mockAuthorizationStatus = .authorizedAlways
        self.testLocationController.mockLocation = AmericaPlacemark.location
        guard let wrongLocationDestinationSingapore = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.singapore).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(wrongLocationDestinationSingapore, .countryComplete(country: self.america))
        
        self.testLocationController.mockLocation = SingaporePlacemark.location
        guard let wrongLocationDestinationUS = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.america).awaitResult(in: self) else {
            return
        }
        
        XCTAssertEqual(wrongLocationDestinationUS, .countryComplete(country: self.america))
        
        self.testLocationController.mockLocation = TuvaluPlacemark.location
        guard let correctDestinationTuvalu = self.testCoordinator.determineDestination(hasSeenInitalVC: true, selectedCountry: self.tuvalu).awaitResult(in: self) else {
            return
        }
        
        let wrongCountry = LocationProblem.authorizedButWrongCountry(expected: "Singapore or the US", actual: self.tuvalu.nameOrPlaceholder)
        XCTAssertEqual(correctDestinationTuvalu, .locationProblem(wrongCountry))
    }
}
