//
//  StageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class StageDeciderTests: XCTestCase {

    struct StageDecider {
        enum Stage: Equatable {
            case home
            case signin
            case onboarding(OnboardingStage)
        }
        
        enum OnboardingStage: Equatable {
            case selectCountry
            case jumio(JumioStage)
        }
        
        enum JumioStage: Equatable {
            case pending
            case failed
        }
        
        func compute(context: Context?, selectedRegion: Region? = nil) -> Stage {
            guard let context = context else {
                return .signin
            }
            
            if let region = context.getRegion() {
                if region.status == .APPROVED {
                    return .home
                } else {
                    return .onboarding(.jumio)
                }
            } else {
                if selectedRegion != nil {
                    return .onboarding(.jumio)
                } else {
                    return .onboarding(.selectCountry)
                }
            }
        }
    }

    func testColdStartForABrandNewUser() {
        let decider = StageDecider()
        
        XCTAssertEqual(decider.compute(context: nil), .signin)
    }
    
    func testSignedInUserWhoHasntSelectedACountry() {
        let decider = StageDecider()
        
        let context = Context(customer: CustomerModel(id: "xxxx", name: "John", email: "jsmith@gmail.com", analyticsId: "xxx", referralId: "xxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context), .onboarding(.selectCountry))
    }
    
    func testSignedInUserWhoHasSelectedACountry() {
        let decider = StageDecider()
        
        let context = Context(customer: CustomerModel(id: "xxxx", name: "John", email: "jsmith@gmail.com", analyticsId: "xxx", referralId: "xxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, selectedRegion: Region(id: "sg", name: "Singapore")), .onboarding(.jumio))
    }
    
    func testStageForSignedUpUser() {
        let decider = StageDecider()

        let context = Context.completedSignaporeUser
        
        XCTAssertEqual(decider.compute(context: context), .home)
    }
}

extension Context {
    static var completedSignaporeUser: Context {
        return Context(customer: CustomerModel(id: "xxxx", name: "John", email: "jsmith@gmail.com", analyticsId: "xxx", referralId: "xxx"), regions: [RegionResponse(region: Region(id: "sg", name: "Singapore"), status: .APPROVED, simProfiles: [SimProfile(eSimActivationCode: "xxxx", alias: "xxxx", iccId: "xxxx", status: .INSTALLED)], kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED))])
    }
}
