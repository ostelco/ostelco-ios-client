//
//  StageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
import ostelco_core

class SingaporeUserHappyFlowWithSingPassStageDeciderTests: XCTestCase {
    // Testing the flow of a singapore user who uses singpass and has no trouble:
    
    let noRegions: [PrimeGQL.RegionDetailsFragment] = []
    
    func testColdStartForAUser() {
        let decider = StageDecider()
        let context: Context? = nil
        
        XCTAssertEqual(decider.compute(context: context, localContext: OnboardingContext()), .loginCarousel)
    }
    
    func testUserNotSignedInColdStart() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext()
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .loginCarousel)
    }
    
    func testUserHasAFirebaseUserButNoContextYet() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext(hasFirebaseToken: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .legalStuff)
    }
    
    func testUserHasAgreedToLegalStuff() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext(hasFirebaseToken: true, hasAgreedToTerms: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .nicknameEntry)
    }
    
    func testUserHasAgreedToLegalStuffThenColdStart() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext(hasFirebaseToken: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .legalStuff)
    }
    
    func testUserHasFirebasedThenColdStartedThenAgreedToLegalStuff() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext(hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenLocationPermissions: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .nicknameEntry)
    }
    
    func testUserHasEnteredNickname() {
        let decider = StageDecider()
        let localContext = OnboardingContext()
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationPermissions)
    }
    
    func testUserHasAcceptedLocationPermissions() {
        let decider = StageDecider()
        let localContext = OnboardingContext(hasSeenLocationPermissions: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: noRegions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .notificationPermissions)
    }
    
    func testUserHasSelectedACountryAndIsInThatCountry() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext, currentCountry: Country("SG"), targetCountry: Country("SG")), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasSelectedSingpass() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .singpass)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext, currentCountry: Country("SG"), targetCountry: Country("SG")), .singpass)
    }
    
    func testUserHasCompletedSingpass() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .singpass, myInfoCode: "xxx")
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: nil, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: nil)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext, currentCountry: Country("SG"), targetCountry: Country("SG")), .verifyMyInfo(code: "xxx"))
    }
    
    func testUserHasCompletedSingpassAndVerifiedTheirAddress() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext, currentCountry: Country("SG"), targetCountry: Country("SG")), .eSimInstructions)
    }
    
    func testUserHasSeenTheESimInstructions() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(hasSeenESIMInstructions: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext, currentCountry: Country("SG"), targetCountry: Country("SG")), .awesome)
    }
    
    func testUserHasInstalledESIMThenColdStart() {
        let decider = StageDecider()
        let localContext = OnboardingContext(hasSeenLocationPermissions: true, hasSeenNotificationPermissions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED, installedReportedByAppOn: "xxx")
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
}
