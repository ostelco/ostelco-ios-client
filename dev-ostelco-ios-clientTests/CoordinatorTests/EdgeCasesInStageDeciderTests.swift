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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .notificationPermissions)
    }
    
    func testUserSignsUpOnNewDeviceAndGivesNotificationPermissionsAfterCompletingOnboardingOnOtherDevice() {
        let decider = StageDecider()
        let localContext = LocalContext(hasFirebaseToken: true, hasSeenNotificationPermissions: true)
        
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
    
    func testUserKillsAppAfterCompletingOnboardingSuccessfullyButBeforeAwesomeScreen() {
        let decider = StageDecider()
        let localContext = LocalContext(hasFirebaseToken: true, hasSeenNotificationPermissions: true)
        
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
        let context: Context? = nil
        let localContext = LocalContext(serverIsUnreachable: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.serverUnreachable))
    }
    
    // Edge cases for Singapore flow
    
    func testUserHasSelectedACountryAndHasLocationProblem() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasSeenNotificationPermissions: true, locationProblem: .deniedByUser)
        let regions: [PrimeGQL.RegionDetailsFragment] = []
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: regions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationProblem(.deniedByUser))
    }
    
    func testUserHasSelectedSingpassAndCancelledSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasSeenLocationPermissions: true)
        let regions: [PrimeGQL.RegionDetailsFragment] = []
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: regions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    func testMyInfoSummaryLoadFailedandSelectedVerificationOptionIsResetToNil() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasSeenLocationPermissions: true)

        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )

        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }

    func testUserHasCompletedNRICAndCancelledJumioInSingapore() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasSeenLocationPermissions: true)
        
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
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: .scanIC, hasSeenLocationPermissions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.ekycRejected))
    }
    
    // Edge cases for Norway flow
    func testUserHasSeenVerifyIdentifyOnboardingAndCancelledJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true, hasSeenLocationPermissions: true)
        let regions: [PrimeGQL.RegionDetailsFragment] = []
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: regions)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasCompletedJumioButGotRejectedInNorway() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasCompletedJumio: true, hasSeenLocationPermissions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.ekycRejected))
    }
    
    // Edge cases where user has started on boarding, thus global context contains a region, but status is PENDING
    func testUserHasSeenVerifyIdentityOnboardingWithNoSelectedCountryAndJumioPendingInNorway() {
            let decider = StageDecider()
            let localContext = LocalContext(hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasSeenLocationPermissions: true)
            
            let context = Context(
                customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
                regions: [
                    RegionResponse(
                        region: Region(id: "no", name: "Norway"),
                        status: .PENDING,
                        simProfiles: nil,
                        kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
                    )
                ])
            
            XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }
    
    func testUserHasSeenVerifyIdentityOnboardingWithNoSelectedCountryAndJumioPendingInSingapore() {
            let decider = StageDecider()
            let localContext = LocalContext(hasSeenNotificationPermissions: true, regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasSeenLocationPermissions: true)
            
            let context = Context(
                customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
                regions: [
                    RegionResponse(
                        region: Region(id: "sg", name: "Singapore"),
                        status: .PENDING,
                        simProfiles: nil,
                        kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
                    )
                ])
            
            XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
}
