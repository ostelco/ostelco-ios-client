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
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasSeenLocationPermissions: true)
        let regions: [PrimeGQL.RegionDetailsFragment] = []
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: regions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }

    func testUserHasCompletedNRIC() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasSeenLocationPermissions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .none, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }
    
    func testUserHasCompletedNRICThenColdStartThenSelectedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: .scanIC, hasSeenLocationPermissions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .none, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }

    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasSeenLocationPermissions: true)
        
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasSeenLocationPermissions: true)
        
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
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasCompletedAddress: true, hasSeenLocationPermissions: true)
        
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
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasCompletedJumio: true, hasSeenLocationPermissions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasCompletedEverythingExceptJumioWhichIsRejectedThenColdStart() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasCompletedJumio: true, hasSeenLocationPermissions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }

    func testUserHasCompletedScanIC() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: .scanIC, hasCompletedJumio: true, hasCompletedAddress: true)
        
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
