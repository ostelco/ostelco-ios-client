//
//  EsimCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class EsimCoordinatorTests: XCTestCase {
    
    private lazy var testCoordinator = ESimCoordinator(navigationController: UINavigationController())
    
    private func createProfile(with status: SimProfileStatus) -> SimProfile {
        return SimProfile(eSimActivationCode: "fake",
                          alias: "something_else",
                          iccId: "identifer",
                          status: status)
    }
    
    func testNilProfileGoesToSetup() {
        let destination = self.testCoordinator.determineDestination(from: nil)
        XCTAssertEqual(destination, .setup)
    }
    
    func testNilProfileAndHasSeenSetupGoesToInstructions() {
        let destination = self.testCoordinator.determineDestination(from: nil, hasSeenSetup: true)
        XCTAssertEqual(destination, .instructions)
    }
    
    func testNilProfileAndHasSeenSetupAndInstructionsGoesToPending() {
        let destination = self.testCoordinator.determineDestination(from: nil, hasSeenSetup: true, hasSeenInstructions: true)
        XCTAssertEqual(destination, .pendingDownload)
    }
    
    func testProfileAvailableForDownloadGoesToPending() {
        let profile = self.createProfile(with: .AVAILABLE_FOR_DOWNLOAD)
        let destination = self.testCoordinator.determineDestination(from: profile)
        XCTAssertEqual(destination, .pendingDownload)
    }
    
    func testProfileDownloadedGoesToSuccess() {
        let profile = self.createProfile(with: .DOWNLOADED)
        let destination = self.testCoordinator.determineDestination(from: profile)
        XCTAssertEqual(destination, .success(profile: profile))
    }
    
    func testProfileDownloadedAndSuccessSeenGoesToCompleted() {
        let profile = self.createProfile(with: .DOWNLOADED)
        let destination = self.testCoordinator.determineDestination(from: profile, hasAcknowledgedSuccess: true)
        XCTAssertEqual(destination, .setupComplete)
    }
    
    func testProfileEnabledGoesToSuccess() {
        let profile = self.createProfile(with: .ENABLED)
        let destination = self.testCoordinator.determineDestination(from: profile)
        XCTAssertEqual(destination, .success(profile: profile))
    }
    
    func testProfileEnabledAndSuccessSeenGoesToCompleted() {
        let profile = self.createProfile(with: .ENABLED)
        let destination = self.testCoordinator.determineDestination(from: profile, hasAcknowledgedSuccess: true)
        XCTAssertEqual(destination, .setupComplete)
    }
    
    func testProfileInstalledGoesToSuccess() {
        let profile = self.createProfile(with: .INSTALLED)
        let destination = self.testCoordinator.determineDestination(from: profile)
        XCTAssertEqual(destination, .success(profile: profile))
    }
    
    func testProfileInstalledAndSuccessSeenGoesToCompleted() {
        let profile = self.createProfile(with: .INSTALLED)
        let destination = self.testCoordinator.determineDestination(from: profile, hasAcknowledgedSuccess: true)
        XCTAssertEqual(destination, .setupComplete)
    }
}
