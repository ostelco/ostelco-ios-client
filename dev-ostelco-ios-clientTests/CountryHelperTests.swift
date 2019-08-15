//
//  CountryHelperTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 8/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import XCTest

class CountryHelperTests: XCTestCase {

    func testLoadResourceFiles() {
        XCTAssertNotNil(CountryHelper.countryListISO2())
        XCTAssertNotNil(CountryHelper.countryListISO3())
    }

    func testISO31662Mapsto3And3MapsTo2() {
        let countryList2 = CountryHelper.countryListISO2()!
        let countryList3 = CountryHelper.countryListISO3()!
        
        for alpha3 in countryList2.values {
            XCTAssertNotNil(countryList3[alpha3])
        }
        
        for alpha2 in countryList3.values {
            XCTAssertNotNil(countryList2[alpha2])
        }
    }
}
