//
//  RegionResponseTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import XCTest

class RegionResponseTests: XCTestCase {
    
    func testApprovedIsReturnedWhenAllArePresent() {
        let regions = [
            RegionResponse.testRejectedRegionRepsonse,
            RegionResponse.testPendingRegionResponse,
            RegionResponse.testApprovedRegionResponse
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "1")
        XCTAssertEqual(region.region.name, "ApprovedRegion")
        XCTAssertEqual(region.status, KycStatus.APPROVED)
    }
    
    func testApprovedIsReturnedWhenOnlyApprovedRejectedPresent() {
        let regions = [
            RegionResponse.testRejectedRegionRepsonse,
            RegionResponse.testApprovedRegionResponse
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "1")
        XCTAssertEqual(region.region.name, "ApprovedRegion")
        XCTAssertEqual(region.status, KycStatus.APPROVED)
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
        XCTAssertEqual(region.status, KycStatus.APPROVED)
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
        XCTAssertEqual(region.status, KycStatus.APPROVED)
    }
    
    func testRejectedIsReturnedWhenPendingAndRejectedPresent() {
        let regions = [
            RegionResponse.testRejectedRegionRepsonse,
            RegionResponse.testPendingRegionResponse,
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "3")
        XCTAssertEqual(region.region.name, "RejectedRegion")
        XCTAssertEqual(region.status, KycStatus.REJECTED)
    }
    
    func testRejectedIsReturnedWhenThatsTheOnlyOption() {
        let regions = [
            RegionResponse.testRejectedRegionRepsonse,
        ]
        
        guard let region = RegionResponse.getRegionFromRegionResponseArray(regions) else {
            XCTFail("This should return a region!")
            return
        }
        
        XCTAssertEqual(region.region.id, "3")
        XCTAssertEqual(region.region.name, "RejectedRegion")
        XCTAssertEqual(region.status, KycStatus.REJECTED)
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
        XCTAssertEqual(region.status, KycStatus.PENDING)
    }
    
    func testNilIsReturnedForAnEmptyArray() {
        XCTAssertNil(RegionResponse.getRegionFromRegionResponseArray([]))
    }
}
