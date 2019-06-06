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
    
    func todo_testEverythingPendingKicksToSelect() {}
    
    func todo_testEverythingApprovedKicksToComplete() {}
    
    func todo_testEverythingRejectedKicksToRejected() {}
    
    func todo_testJustJumioRejectedAlwaysKicksToRejected() {}
    
    func todo_testJumioAndAddressAndNRICApprovedKicksToComplete() {}
    
    func todo_testNRICApprovedAndEverythingElsePendingKicksToJumio() {}
    
    func todo_testNRICAndJumioApprovedAndEverythingElsePendingKicksToAddress() {}
    
    func todo_testJumioApprovedAndEverythingElsePendingKicksToNRIC() {}
    
    func todo_testJumioAndAddressApprovedAndEverythingElsePendingKicksToNRIC() {}
    
    func todo_testMyInfoApprovedAndEverythingElsePendingKicksToAddress() {}
    
    func todo_testMyInfoAndAddressApprovedAndEverythingElsePendingKicksToComplete() {}
    
    // MARK: - SingPass Flow
    
    func testSingPassFlowWithNothingKicksToStartingPage() {
        let destination = self.testCoordinator.determineSingPassFlowDestination()
        XCTAssertEqual(destination, .singPass)
    }
    
    func testSingPassFlowWithURLQueryParamsKicksToSingpassAddressVerify() {
        let urlQueryItem = URLQueryItem(name: "test", value: "test")
        let items = [urlQueryItem]
        
        let destination = self.testCoordinator.determineSingPassFlowDestination(singPassQueryItems: items)
        XCTAssertEqual(destination, .verifySingPassAddress(queryItems: items))
    }
    
    func testSingPassFlowWithDelegateAndNilAddressKicksToSingpassAddressEdit() {
        let destination = self.testCoordinator.determineSingPassFlowDestination(address: nil, editDelegate: self)
        XCTAssertEqual(destination, .editSingPassAddress(address: nil, delegate: self))
    }
    
    func testSingPassFlowWithDelegateAndNonNilAddressKicksToSingpassAddressEdit() {
        guard let address = MyInfoDetails.testInfo?.address else {
            XCTFail("Couldn't grab test address")
            return
        }
        
        let destination = self.testCoordinator.determineSingPassFlowDestination(address: address, editDelegate: self)
        XCTAssertEqual(destination, .editSingPassAddress(address: address, delegate: self))
    }
    
    // MARK: - NRIC / Jumio / Address flow
    
    func testNRICFlowWithNothingKicksToSteps() {
        let destination = self.testCoordinator.determineNRICFlowDestination()
        XCTAssertEqual(destination, .stepsForNRIC)
    }
    
    func testNRICFlowWithStepsViewedKicksToEnterNRIC() {
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true)
        XCTAssertEqual(destination, .enterNRIC)
    }
    
    func testNRICFlowWithValidatedNRICKicksToJumio() {
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true,
                                                                            validatedNRIC: true)
        XCTAssertEqual(destination, .jumio)
    }
    
    func testNRICFlowWithJumioCompletedKicksToAddress() {
        let destination = self.testCoordinator.determineNRICFlowDestination(viewedSteps: true,
                                                                            validatedNRIC: true,
                                                                            completedJumio: true)
        XCTAssertEqual(destination, .enterAddress)
    }
}

extension SingaporeEKYCCoordinatorTests: MyInfoAddressUpdateDelegate {
    func addressUpdated(to address: MyInfoAddress) {}
}
