//
//  SingaporeEKYCCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class SingaporeEKYCCoordinatorTests: XCTestCase {
    
    private lazy var testCoordinator = SingaporeEKYCCoordinator(navigationController: UINavigationController())
    
    private func createTestRegion(status: EKYCStatus,
                                  jumioStatus: EKYCStatus,
                                  myInfoStatus: EKYCStatus,
                                  nricFinStatus: EKYCStatus,
                                  addressPhoneStatus: EKYCStatus) -> RegionResponse {
        let region = Region(id: "sg", name: "Singapore")
        let statusMap = KYCStatusMap(jumio: jumioStatus,
                                     myInfo: myInfoStatus,
                                     nricFin: nricFinStatus,
                                     addressPhone: addressPhoneStatus)
        return RegionResponse(region: region,
                              status: status,
                              simProfiles: nil,
                              kycStatusMap: statusMap)
    }
    
    func testNoRegionAndHasntSeenLandingKicksToLanding() {
        let destination = self.testCoordinator.determineDestination(from: nil)
        XCTAssertEqual(destination, .landing)
    }
    
    func testNoRegionAndHasSeenLandingKicksToSelectVerificationMethod() {
        let destination = self.testCoordinator.determineDestination(from: nil, hasSeenLanding: true)
        XCTAssertEqual(destination, .selectVerificationMethod)
    }
    
    func testRegionAcceptedKicksToSuccess() {
        let testRegion = self.createTestRegion(status: .APPROVED,
                                               jumioStatus: .APPROVED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .APPROVED)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .success(region: testRegion))
    }
    
    func testRegionRejectedKicksToRejected() {
        let testRegion = self.createTestRegion(status: .REJECTED,
                                               jumioStatus: .REJECTED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .APPROVED)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .ekycRejected)
    }
    
    // MARK: - Alllllll the pending permutations
    
    func testEverythingPendingKicksToSelectVerificationMethod() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .selectVerificationMethod)
    }
    
    func testEverythingApprovedKicksToSuccess() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .APPROVED,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .APPROVED,
                                               addressPhoneStatus: .APPROVED)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .success(region: testRegion))
    }
    
    func testEverythingRejectedKicksToRejected() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .REJECTED,
                                               myInfoStatus: .REJECTED,
                                               nricFinStatus: .REJECTED,
                                               addressPhoneStatus: .REJECTED)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .ekycRejected)
    }
    
    func testAddressRejectedAlwaysKicksToRejected() {
        for nricStatus in EKYCStatus.allCases {
            for jumioStatus in EKYCStatus.allCases {
                for myInfoStatus in EKYCStatus.allCases {
                    let testRegion = self.createTestRegion(status: .PENDING,
                                                           jumioStatus: jumioStatus,
                                                           myInfoStatus: myInfoStatus,
                                                           nricFinStatus: nricStatus,
                                                           addressPhoneStatus: .REJECTED)
                    let destination = self.testCoordinator.determineDestination(from: testRegion)
                    XCTAssertEqual(destination,
                                   .ekycRejected,
                                   "Expected ekycRejected but got \(destination) instead - jumio \(jumioStatus) nric \(nricStatus), myInfo \(myInfoStatus)")
                }
            }
        }
    }
    
    func testJumioAndMyInfoBothRejectedAlwaysKicksToRejected() {
        for nricStatus in EKYCStatus.allCases {
            for addressPhoneStatus in EKYCStatus.allCases {
                let testRegion = self.createTestRegion(status: .PENDING,
                                                       jumioStatus: .REJECTED,
                                                       myInfoStatus: .REJECTED,
                                                       nricFinStatus: nricStatus,
                                                       addressPhoneStatus: addressPhoneStatus)
                let destination = self.testCoordinator.determineDestination(from: testRegion)
                XCTAssertEqual(destination,
                               .ekycRejected,
                               "Expected ekycRejected but got \(destination) instead - nric \(nricStatus), addressPhone \(addressPhoneStatus)")
            }
        }
    }
    
    func testMyInfoAndAddressApprovedAlwaysKicksToSuccess() {
        for jumioStatus in EKYCStatus.allCases {
            for nricStatus in EKYCStatus.allCases {
                let testRegion = self.createTestRegion(status: .PENDING,
                                                       jumioStatus: jumioStatus,
                                                       myInfoStatus: .APPROVED,
                                                       nricFinStatus: nricStatus,
                                                       addressPhoneStatus: .APPROVED)
                let destination = self.testCoordinator.determineDestination(from: testRegion)
                XCTAssertEqual(destination,
                               .success(region: testRegion),
                               "Expected success, got \(destination) instead - jumio \(jumioStatus), nric \(nricStatus)")
            }
        }
    }
    
    func testJumioAddressAndNRICApprovedAlwaysKicksToSuccess() {
        for myInfoStatus in EKYCStatus.allCases {
            let testRegion = self.createTestRegion(status: .PENDING,
                                                   jumioStatus: .APPROVED,
                                                   myInfoStatus: myInfoStatus,
                                                   nricFinStatus: .APPROVED,
                                                   addressPhoneStatus: .APPROVED)
            let destination = self.testCoordinator.determineDestination(from: testRegion)
            XCTAssertEqual(destination,
                           .success(region: testRegion),
                           "Expected success, got \(destination) instead - my info \(myInfoStatus)")
        }
    }
    
    func testJumioRejectedAndEverythingElsePendingKicksToSingPass() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .REJECTED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .singPass)
    }
    
    func testJumioRejectedAndMyInfoApprovedKicksToVerify() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .REJECTED,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .verifySingPassAddress)
    }
    
    func testNRICApprovedAndEverythingElsePendingKicksToJumio() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .APPROVED,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .jumio)
    }
    
    func testNRICRejectedAndEverythingElsePendingKicksToSingPass() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .REJECTED,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .singPass)
    }
    
    func testNRICAndJumioApprovedAndEverythingElsePendingKicksToAddress() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .APPROVED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .APPROVED,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .enterAddress(hasCompletedJumio: true))
    }
    
    func testJumioApprovedAndEverythingElsePendingKicksToNRIC() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .APPROVED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .enterNRIC)
    }
    
    func testJumioAndAddressApprovedAndEverythingElsePendingKicksToNRIC() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .APPROVED,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .APPROVED)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .enterNRIC)
    }
    
    func testMyInfoApprovedAndEverythingElsePendingKicksToVerifyAddress() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineDestination(from: testRegion)
        XCTAssertEqual(destination, .verifySingPassAddress)
    }
    
    // MARK: - SingPass Flow
    
    func testSingPassFlowWithNilRegionKicksToStartingPage() {
        let destination = self.testCoordinator.determineSingPassFlowDestination(region: nil)
        XCTAssertEqual(destination, .singPass)
    }
    
    func testSingPassFlowWithEverythingPendingKicksToStartingPage() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineSingPassFlowDestination(region: testRegion)
        XCTAssertEqual(destination, .singPass)
    }
    
    func testSingPassFlowWithMyInfoApprovedAndAddressPendingKicksToSingpassAddressVerify() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        
        let destination = self.testCoordinator.determineSingPassFlowDestination(region: testRegion)
        XCTAssertEqual(destination, .verifySingPassAddress)
    }
    
    func testSingPassFlowWithWithMyInfoApprovedAndAddressPendingAndHasDelegateAndNilAddressKicksToSingpassAddressEdit() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        
        let destination = self.testCoordinator.determineSingPassFlowDestination(region: testRegion, address: nil, editDelegate: self)
        XCTAssertEqual(destination, .editSingPassAddress(address: nil, delegate: self))
    }
    
    func testSingPassFlowWithDelegateAndNonNilAddressKicksToSingpassAddressEdit() {
        guard let address = MyInfoDetails.testInfo?.address else {
            XCTFail("Couldn't grab test address")
            return
        }
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .APPROVED,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        
        let destination = self.testCoordinator.determineSingPassFlowDestination(region: testRegion, address: address, editDelegate: self)
        XCTAssertEqual(destination, .editSingPassAddress(address: address, delegate: self))
    }
    
    // MARK: - NRIC / Jumio / Address flow
    
    func testNRICFlowWithoutHavingViewedStepsKicksToSteps() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineNRICFlowDestination(region: testRegion)
        XCTAssertEqual(destination, .stepsForNRIC)
    }
    
    func testNRICFlowWithStepsViewedAndNilRegionKicksToEnterNRIC() {
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true, region: nil)
        XCTAssertEqual(destination, .enterNRIC)
    }
    
    func testNRICFlowWithStepsViewedAndPendingRegionKicksToEnterNRIC() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .PENDING,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true, region: testRegion)
        XCTAssertEqual(destination, .enterNRIC)
    }
    
    func testNRICFlowWithApprovedNRICKicksToJumio() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .APPROVED,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true,
                                                                            region: testRegion)
        XCTAssertEqual(destination, .jumio)
    }
    
    func testNRICFlowWithJumioCompletedKicksToAddress() {
        let testRegion = self.createTestRegion(status: .PENDING,
                                               jumioStatus: .PENDING,
                                               myInfoStatus: .PENDING,
                                               nricFinStatus: .APPROVED,
                                               addressPhoneStatus: .PENDING)
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true,
                                                                            region: testRegion,
                                                                            completedJumio: true)
        XCTAssertEqual(destination, .enterAddress(hasCompletedJumio: true))
    }
}

extension SingaporeEKYCCoordinatorTests: MyInfoAddressUpdateDelegate {
    func addressUpdated(to address: MyInfoAddress) {}
}
