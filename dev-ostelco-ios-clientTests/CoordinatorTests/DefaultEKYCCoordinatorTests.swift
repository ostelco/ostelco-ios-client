//
//  DefaultEKYCCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class DefaultEKYCCoordinatorTests: XCTestCase {
    
    private lazy var testCoordinator = DefaultEKYCCoordinator(navigationController: UINavigationController(),
                                                              country: Country("us"))
    
    func createTestRegion(status: EKYCStatus,
                          jumioStatus: EKYCStatus) -> RegionResponse {
        let region = Region(id: "us", name: "United States")
        let statusMap = KYCStatusMap(jumio: jumioStatus)
        return RegionResponse(region: region,
                              status: status,
                              simProfiles: nil,
                              kycStatusMap: statusMap)
    }
    
    func testNoRegionAndHasntSeenLandingKicksToLanding() {
        let destination = self.testCoordinator.determineDestination(from: nil)
        XCTAssertEqual(destination, .landing)
    }
    
    func testNoRegionAndHasSeenLandingKicksToJumio() {
        let destination = self.testCoordinator.determineDestination(from: nil, hasSeenLanding: true)
        XCTAssertEqual(destination, .jumio)
    }
    
    func testDestinationWithRegionPendingAndJumioPendingKicksToWaiting() {
        let region = self.createTestRegion(status: .PENDING,
                                           jumioStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: region)
        XCTAssertEqual(destination, .waitingForVerification)
    }
    
    func testDestinationWithRegionPendingAndJumioRejectedKicksToRejected() {
        let region = self.createTestRegion(status: .PENDING,
                                           jumioStatus: .REJECTED)
        let destination = self.testCoordinator.determineDestination(from: region)
        XCTAssertEqual(destination, .ekycRejected)
    }
    
    func testDestinationWithRegionPendingAndJumioApprovedKicksToSuccess() {
        let region = self.createTestRegion(status: .PENDING,
                                           jumioStatus: .APPROVED)
        let destination = self.testCoordinator.determineDestination(from: region)
        XCTAssertEqual(destination, .success(region: region))
    }
    
    func testDestinationWithRegionRejectedKicksToRejected() {
        let region = self.createTestRegion(status: .REJECTED,
                                           jumioStatus: .APPROVED) // This should be ignored here.
        let destination = self.testCoordinator.determineDestination(from: region)
        XCTAssertEqual(destination, .ekycRejected)
    }
    
    func testDestinationWithRegionApprovedKicksToApproved() {
        let region = self.createTestRegion(status: .APPROVED,
                                           jumioStatus: .REJECTED) // This should be ignored here.
        let destination = self.testCoordinator.determineDestination(from: region)
        XCTAssertEqual(destination, .success(region: region))
    }
    
}
