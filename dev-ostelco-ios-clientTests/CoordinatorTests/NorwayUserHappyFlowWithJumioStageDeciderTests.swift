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
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"))
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationPermissions)
    }
    
    func testUserHasSelectedACountryAndIsInThatCountry() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasSeenVerifyIdentifyOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .jumio)
    }
    
    func testUserHasCompletedJumio() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "no", name: "Norway"),
                    status: .PENDING,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .pendingVerification)
    }
    
    func testUserHasCompletedJumioAndIsApproved() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "no", name: "NO"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, hasCompletedJumio: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "no", name: "Norway"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimOnboarding)
    }
}
