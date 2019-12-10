//
//  RegionResponseTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import Oya_Development_app

class RegionResponseTests: XCTestCase {
    
    func testApprovedIsReturnedWhenAllArePresent() {
        let regions = [
            RegionResponse.testPendingRegionResponse,
            RegionResponse.testApprovedRegionResponse
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "1")
        XCTAssertEqual(region.region.name, "ApprovedRegion")
        XCTAssertEqual(region.status, .approved)
    }
    
    func testApprovedIsReturnedWhenOnlyApprovedPendingPresent() {
        let regions = [
            RegionResponse.testPendingRegionResponse,
            RegionResponse.testApprovedRegionResponse
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "1")
        XCTAssertEqual(region.region.name, "ApprovedRegion")
        XCTAssertEqual(region.status, .approved)
    }
    
    func testApprovedIsReturnedWhenThatsTheOnlyOption() {
        let regions = [
            RegionResponse.testApprovedRegionResponse
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "1")
        XCTAssertEqual(region.region.name, "ApprovedRegion")
        XCTAssertEqual(region.status, .approved)
    }
    
    func testPendingIsReturnedWhenThatsTheOnlyOption() {
        let regions = [
            RegionResponse.testPendingRegionResponse,
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "2")
        XCTAssertEqual(region.region.name, "PendingRegion")
        XCTAssertEqual(region.status, .pending)
    }
    
    func testNilIsReturnedForAnEmptyArray() {
        XCTAssertNil(RegionResponse.getRegionFromRegionResponseArray([]))
    }
}
