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
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC)
        
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .nric)
    }

    func testUserHasCompletedNRIC() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }
    
    func testUserHasCompletedNRICThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }

    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC, hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .address)
    }
    
    func testUserHasCompletedNRICAndJumioThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC, hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .address)
    }

    func testUserHasCompletedAddress() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasCompletedAddress: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .pendingVerification)
    }
    
    func testUserHasCompletedEverythingExceptJumioWhichIsPendingThenColdStart() {
        let decider = StageDecider()
        let localContext = LocalContext(hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .pendingVerification)
    }
    
    func testUserHasCompletedEverythingExceptJumioWhichIsRejectedThenColdStart() {
        let decider = StageDecider()
        let localContext = LocalContext(hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .REJECTED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.ekycRejected))
    }

    func testUserHasCompletedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasCompletedAddress: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimOnboarding)
    }
    
    // Everything after this point is the exact same as in SingaporeUserHappyFlowWithSingPassStageDeciderTests
}
