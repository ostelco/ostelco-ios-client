//
//  ContextTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Samuel Goodwin on 7/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import Oya_Development_app

class ContextTests: XCTestCase {

    var bundle: Bundle {
        return Bundle(for: classForCoder)
    }
    
    func testDecodingContextWithTooManyProfiles() throws {
        let url = bundle.url(forResource: "context_with_too_many_profiles", withExtension: "json", subdirectory: "MockJSON")!
        let data = try Data(contentsOf: url)
        
        let context = try JSONDecoder().decode(DecodableContext.self, from: data).toContext()
        
        let region = context.getRegion()
        XCTAssertNotNil(region)
        
        XCTAssertEqual(region?.region.name, "Norway")
        
        let profiles = region?.simProfiles
        
        XCTAssert(profiles!.isNotEmpty)
    }
    
    func testSimProfilesCountAsInstalledWhenRightPropertiesAreSet() {
        let first = SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .AVAILABLE_FOR_DOWNLOAD, installedReportedByAppOn: "someDateThatIsGoodWeDontCare")
        XCTAssert(first.isInstalled)
        
        let second = SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED, installedReportedByAppOn: nil)
        XCTAssert(second.isInstalled)
    }

}
