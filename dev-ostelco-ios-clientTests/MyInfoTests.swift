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
        XCTAssertEqual(testInfo.sex, "F")
        XCTAssertEqual(testInfo.dob, "1998-06-06")
        XCTAssertEqual(testInfo.residentialStatus, "C")
        XCTAssertEqual(testInfo.nationality, "SG")
        XCTAssertEqual(testInfo.email, "myinfotesting@gmail.com")
        
        let address = testInfo.address
        XCTAssertEqual(address.unit, "128")
        XCTAssertEqual(address.street, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.block, "102")
        XCTAssertEqual(address.postal, "460102")
        XCTAssertEqual(address.floor, "09")
        XCTAssertEqual(address.building, "PEARL GARDEN")
        
        XCTAssertEqual(address.addressLine1, "102 BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.addressLine2, "460102 SG")
        XCTAssertEqual(address.formattedAddress, "102 BEDOK NORTH AVENUE 4\n460102 SG")
        
        guard let mobileNumber = testInfo.mobileNumber else {
            XCTFail("Could not access mobile number!")
            return
        }
        XCTAssertEqual(mobileNumber.code, "65")
        XCTAssertEqual(mobileNumber.prefix, "+")
        XCTAssertEqual(mobileNumber.number, "97399245")
        XCTAssertEqual(mobileNumber.formattedNumber, "+6597399245")
    }
    
    func testAddressFormattingWithMissingBlock() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: nil,
                                    building: "PEARL GARDEN",
                                    street: "BEDOK NORTH AVENUE 4",
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.addressLine2, "460102 SG")
        XCTAssertEqual(address.formattedAddress, "BEDOK NORTH AVENUE 4\n460102 SG")
    }
    
    func testAddressFormattingWithMissingStreet() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: "102",
                                    building: "PEARL GARDEN",
                                    street: nil,
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "102")
        XCTAssertEqual(address.addressLine2, "460102 SG")
        XCTAssertEqual(address.formattedAddress, "102\n460102 SG")
    }
    
    func testAddressFormattingWithMissingPostcode() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: "102",
                                    building: "PEARL GARDEN",
                                    street: "BEDOK NORTH AVENUE 4",
                                    postal: nil)
    
        XCTAssertEqual(address.addressLine1, "102 BEDOK NORTH AVENUE 4")
        XCTAssertEqual(address.addressLine2, "SG")
        XCTAssertEqual(address.formattedAddress, "102 BEDOK NORTH AVENUE 4\nSG")
    }
    
    func testAddressFormattingWithMissingBlockAndStreet() {
        let address = MyInfoAddress(floor: "SG",
                                    unit: "128",
                                    block: nil,
                                    building: "PEARL GARDEN",
                                    street: nil,
                                    postal: "460102")
        
        XCTAssertEqual(address.addressLine1, "")
        XCTAssertEqual(address.addressLine2, "460102 SG")
        XCTAssertEqual(address.formattedAddress, "460102 SG")
    }
}
