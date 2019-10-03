//
//  StageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class SingaporeUserHappyFlowWithSingPassStageDeciderTests: XCTestCase {
    // Testing the flow of a singapore user who uses singpass and has no trouble:
    
    let noRegions: [PrimeGQL.RegionDetailsFragment] = []
    
    func testColdStartForAUser() {
        let decider = StageDecider()
        let context: Context? = nil
        
        XCTAssertEqual(decider.compute(context: context, localContext: LocalContext()), .loginCarousel)
    }
    
    func testUserNotSignedInColdStart() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext()
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .loginCarousel)
    }
    
    func testUserHasAFirebaseUserButNoContextYet() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext(hasFirebaseToken: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .legalStuff)
    }
    
    func testUserHasAgreedToLegalStuff() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext(hasFirebaseToken: true, hasAgreedToTerms: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .nicknameEntry)
    }
    
    func testUserHasAgreedToLegalStuffThenColdStart() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext(hasFirebaseToken: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .legalStuff)
    }
    
    func testUserHasFirebasedThenColdStartedThenAgreedToLegalStuff() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext(hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenLocationPermissions: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .nicknameEntry)
    }
    
    func testUserHasEnteredNickname() {
        let decider = StageDecider()
        let localContext = LocalContext()
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
    
    func testUserHasSelectedACountryAndIsInThatCountry() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasSelectedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: .singpass, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .singpass)
    }
    
    func testUserHasCompletedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, selectedVerificationOption: .singpass, myInfoCode: "xxx", hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: nil, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: nil)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .verifyMyInfo(code: "xxx"))
    }
    
    func testUserHasCompletedSingpassAndVerifiedTheirAddress() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenLocationPermissions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .eSimOnboarding)
    }
    
    func testUserHasSeenTheESimOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .eSimInstructions)
    }
    
    func testUserHasSeenTheESimInstructions() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true, hasSeenESIMInstructions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .done)
    }
    
    func testUserHasInstalledESIMThenColdStart() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true)
        
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
    
    func testUserHasInstalledESIMAndSeenAwesome() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true, hasSeenESIMInstructions: true, hasSeenAwesome: true)
        
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
}
