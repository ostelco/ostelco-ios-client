//
//  EdgeCasesInStageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class EdgeCasesInStageDeciderTests: XCTestCase {

    // Existing Singapore user who logs in to a new device but has completed the onboarding on a different device.
    
    func testUserSignsUpOnNewDeviceAfterCompletingOnboardingOnOtherDevice() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenLoginCarousel: true, enteredEmailAddress: "xxxx@gmail.com", hasFirebaseToken: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED)
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
    
    // What does this actually mean? Rename test
    func testUserKillsAppAfterCompletingOnboardingSuccessfullyButBeforeAwesomeScreen() {
        let decider = StageDecider()
        let localContext = LocalContext(hasFirebaseToken: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED)
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
    
    func testServerIsUnavailableOnStartUp() {
        let decider = StageDecider()
        let localContext = LocalContext(serverIsUnreachable: true)
        
        XCTAssertEqual(decider.compute(context: nil, localContext: localContext), .ohNo(.noInternet))
    }
    
    // Edge cases for Singapore flow
    
    func testUserHasSelectedACountryAndHasLocationProblem() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasLocationProblem: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationProblem)
    }
    
    func testUserHasSelectedSingpassAndCancelledSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true)
        
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasCompletedNRICAndCancelledJumioInSingapore() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasCompletedJumioButGotRejected() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.scanIC, hasCompletedJumio: true, hasCompletedAddress: true)
        
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
        
        // TODO: send user to ekyc on boarding, then select identity verification method, THEN show .ohNo(.ekycRejected) IF they selected ScanIC
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.ekycRejected))
    }
    
    // Edge cases for Norway flow
    func testUserHasSeenVerifyIdentifyOnboardingAndCancelledJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasCancelledJumio: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasCompletedJumioButGotRejectedInNorway() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "no", name: "Norway"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        // TODO: send user to ekyc on boarding, THEN show .ohNo(.ekycRejected) 
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.ekycRejected))
    }

}
