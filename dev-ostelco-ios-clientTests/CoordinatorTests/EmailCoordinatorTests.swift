//
//  EmailCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
@testable import Oya_Development_app
import XCTest

class EmailCoordinatorTests: XCTestCase {
    
    private lazy var testCoordinator = EmailCoordinator(navigationController: UINavigationController())
    
    func testNoEmailEnteredKicksToEmailEntry() {
        let destination = self.testCoordinator.determineDestination(emailEntered: false)
        XCTAssertEqual(destination, .enterEmail)
    }
    
    func testEnteredButNotVerifiedEmailKicksToVerify() {
        let destination = self.testCoordinator.determineDestination(emailEntered: true)
        XCTAssertEqual(destination, .verifyEmail)
    }
    
    func testEmailEnteredAndVerifiedKicksToVerified() {
        let destination = self.testCoordinator.determineDestination(emailEntered: true, emailVerified: true)
        XCTAssertEqual(destination, .emailVerified)
    }
}
