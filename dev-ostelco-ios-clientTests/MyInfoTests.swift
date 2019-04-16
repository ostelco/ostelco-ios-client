//
//  MyInfoTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class MyInfoTests: XCTestCase {
    
    func testMyInfoDetailsParsesCorrectlyFromLocalData() {
        guard let testInfo = MyInfoDetails.testInfo else {
            XCTFail("Could not parse test info!")
            return
        }
        
        XCTAssertEqual(testInfo.name, "TAN XIAO HUI")
        XCTAssertEqual(testInfo.sex, "F")
        XCTAssertEqual(testInfo.dob, "1970-05-17")
        XCTAssertEqual(testInfo.residentialStatus, "C")
        XCTAssertEqual(testInfo.nationality, "SG")
        XCTAssertEqual(testInfo.email, "myinfotesting@gmail.com")
        
        let address = testInfo.address
        XCTAssertEqual(address.country, "SG")
        XCTAssertEqual(address.unit, "128")
        XCTAssertEqual(address.street, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.block, "102")
        XCTAssertEqual(address.postal, "460102")
        XCTAssertEqual(address.floor, "09")
        XCTAssertEqual(address.building, "PEARL GARDEN")
        
        guard let mobileNumber = testInfo.mobileNumber else {
            XCTFail("Could not access mobile number!")
            return
        }
        XCTAssertEqual(mobileNumber.code, "65")
        XCTAssertEqual(mobileNumber.prefix, "+")
        XCTAssertEqual(mobileNumber.number, "97399245")
        XCTAssertEqual(mobileNumber.formattedNumber, "+6597399245")
    }
}
