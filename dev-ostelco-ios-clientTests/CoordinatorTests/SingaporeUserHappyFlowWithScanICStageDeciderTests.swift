//
//  SingaporeUserHappFlowWithScanICStageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 7/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
import ostelco_core

class SingaporeUserHappyFlowWithScanICStageDeciderTests: XCTestCase {
    
    // Everything up to this point is the exact same as in SingaporeUserHappyFlowWithSingPassStageDeciderTests
    
    func testUserHasSelectedScanIC() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: IdentityVerificationOption.scanIC)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumioInstructions)
    }

    func testUserHasCompletedNRICButSelectedScanIC() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: IdentityVerificationOption.scanIC)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumioInstructions)
    }
    
    func testUserHasCompletedNRICThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumioInstructions)
    }

    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCompletedJumio: true, hasSeenJumioInstructions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .address)
    }
    
    func testUserHasCompletedNRICAndJumioThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCompletedJumio: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .address)
    }

    func testUserHasCompletedAddress() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCompletedJumio: true, hasSeenJumioInstructions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .pendingVerification)
    }
    
    func testUserHasCompletedEverythingExceptJumioWhichIsPendingThenColdStart() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasCompletedEverythingExceptJumioWhichIsRejectedThenColdStart() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }

    func testUserHasCompletedScanIC() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCompletedJumio: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .eSimInstructions)
    }
    
    // Everything after this point is the exact same as in SingaporeUserHappyFlowWithSingPassStageDeciderTests
}
