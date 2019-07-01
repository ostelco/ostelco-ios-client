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
    
    func testUserKillsAppAfterFinishing() {
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

}
