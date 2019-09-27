//
//  MyInfoTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import XCTest

class MyInfoTests: XCTestCase {
    
    func testMyInfoDetailsParsesCorrectlyFromLocalData() {
        guard let testInfo = MyInfoDetails.testInfo else {
            XCTFail("Could not parse test info!")
            return
        }
        
        XCTAssertEqual(testInfo.name, "TAN XIAO HUI")
        XCTAssertEqual(testInfo.dob, "1998-06-06")
        
        let address = testInfo.address
        XCTAssertEqual(address.unit, "128")
        XCTAssertEqual(address.street, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.block, "102")
        XCTAssertEqual(address.postal, "460102")
        XCTAssertEqual(address.floor, "09")
        XCTAssertEqual(address.building, "PEARL GARDEN")
        
        XCTAssertEqual(address.addressLine1, "#09-128, 102 PEARL GARDEN")
        XCTAssertEqual(address.addressLine2, "BEDOK NORTH AVENUE 4, 460102")
        XCTAssertEqual(address.formattedAddress, "#09-128, 102 PEARL GARDEN\nBEDOK NORTH AVENUE 4, 460102")
    }
    
    func testAddressFormattingWithMissingBlock() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: nil,
                                    building: "PEARL GARDEN",
                                    street: "BEDOK NORTH AVENUE 4",
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "#SG-128, PEARL GARDEN")
        XCTAssertEqual(address.addressLine2, "BEDOK NORTH AVENUE 4, 460102")
        XCTAssertEqual(address.formattedAddress, "#SG-128, PEARL GARDEN\nBEDOK NORTH AVENUE 4, 460102")
    }
    
    func testAddressFormattingWithMissingStreet() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: "102",
                                    building: "PEARL GARDEN",
                                    street: nil,
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "#SG-128, 102 PEARL GARDEN")
        XCTAssertEqual(address.addressLine2, "460102")
        XCTAssertEqual(address.formattedAddress, "#SG-128, 102 PEARL GARDEN\n460102")
    }
    
    func testAddressFormattingWithMissingPostcode() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: "102",
                                    building: "PEARL GARDEN",
                                    street: "BEDOK NORTH AVENUE 4",
                                    postal: nil)
    
        XCTAssertEqual(address.addressLine1, "#SG-128, 102 PEARL GARDEN")
        XCTAssertEqual(address.addressLine2, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.formattedAddress, "#SG-128, 102 PEARL GARDEN\nBEDOK NORTH AVENUE 4")
    }
    
    func testAddressFormattingWithMissingBlockAndStreet() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: nil,
                                    building: "PEARL GARDEN",
                                    street: nil,
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "#SG-128, PEARL GARDEN")
        XCTAssertEqual(address.addressLine2, "460102")
        XCTAssertEqual(address.formattedAddress, "#SG-128, PEARL GARDEN\n460102")
    }
}
