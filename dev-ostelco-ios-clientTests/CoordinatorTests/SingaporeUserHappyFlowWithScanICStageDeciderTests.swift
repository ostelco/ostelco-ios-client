//
//  SingaporeUserHappFlowWithScanICStageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 7/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class SingaporeUserHappyFlowWithScanICStageDeciderTests: XCTestCase {
    
    // Everything up to this point is the exact same as in SingaporeUserHappyFlowWithSingPassStageDeciderTests
    
    func testUserHasSelectedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumio)
    }

    func testUserHasCompletedNRIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .none, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumio)
    }
    
    func testUserHasCompletedNRICThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: .scanIC, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .none, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumio)
    }

    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasSeenLocationPermissions: true)
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasSeenLocationPermissions: true)
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasCompletedAddress: true, hasSeenLocationPermissions: true)
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasCompletedJumio: true, hasSeenLocationPermissions: true)
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasCompletedJumio: true, hasSeenLocationPermissions: true)
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: .scanIC, hasCompletedJumio: true, hasCompletedAddress: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .eSimOnboarding)
    }
    
    // Everything after this point is the exact same as in SingaporeUserHappyFlowWithSingPassStageDeciderTests
}
