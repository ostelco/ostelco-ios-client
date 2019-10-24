//
//  NorwayUserHappyFlowWithJumioStageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 7/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class NorwayUserHappyFlowWithJumioStageDeciderTests: XCTestCase {
    func testUserHasSelectedACountry() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: nil, myInfo: nil, nricFin: nil, addressPhone: nil)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.jumio]))
    }
    
    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .jumio, hasCompletedJumio: true, hasSeenJumioInstructions: true)
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .address)
    }
    
    func testUserHasCompletedJumioAndAddress() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .jumio, hasCompletedJumio: true, hasSeenJumioInstructions: true)
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .pendingVerification)
    }
    
    func testUserHasCompletedJumioAndIsApproved() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(hasCompletedJumio: true)
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .eSimInstructions)
    }
}
