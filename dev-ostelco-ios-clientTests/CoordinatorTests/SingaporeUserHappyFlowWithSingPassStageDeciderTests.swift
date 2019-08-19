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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationPermissions)
    }
    
    func testUserHasAcceptedLocationPermissions() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = LocalContext(hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenLocationPermissions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .notificationPermissions)
    }
    
    func testUserHasSeenNotificationPermissions() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .regionOnboarding)
    }
    
    func testUserHasSeenRegionOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenRegionOnboarding: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectRegion)
    }
    
    func testUserHasSelectedACountryAndIsInThatCountry() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasSeenVerifyIdentifyOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasSelectedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: .singpass)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .singpass)
    }
    
    func testUserHasCompletedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: .singpass, myInfoCode: "xxx")
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyMyInfo(code: "xxx"))
    }
    
    func testUserHasCompletedSingpassThenColdStart() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, myInfoCode: "xxx")
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .regionOnboarding)
    }
    
    func testUserHasCompletedSingpassAndVerifiedTheirAddress() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimOnboarding)
    }
    
    func testUserHasSeenTheESimOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimInstructions)
    }
    
    func testUserHasSeenTheESimInstructions() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true, hasSeenESIMInstructions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .pendingESIMInstall)
    }
    
    func testUserHasInstalledESIM() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenNotificationPermissions: true, hasSeenESimOnboarding: true, hasSeenESIMInstructions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .awesome)
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
