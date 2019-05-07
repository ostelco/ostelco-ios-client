//
//  EmailValidatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class EmailValidatorTests: XCTestCase {
    
    private lazy var validator = EmailValidator()
    
    func testInitialValidationIsIgnoredWhenStartingFromNotChecked() {
        XCTAssertEqual(validator.validationState, .notChecked)
        
        self.validator.email = nil
        XCTAssertEqual(self.validator.validationState, .notChecked)
        self.validator.email = ""
        XCTAssertEqual(self.validator.validationState, .notChecked)
        self.validator.email = "1"
        XCTAssertEqual(self.validator.validationState, .notChecked)
        self.validator.email = "12"
        XCTAssertEqual(self.validator.validationState, .notChecked)
        self.validator.email = "123"
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterValidErrorCopy))

        // Now that it's gone off of `notChecked`, it should validate backspacing
        self.validator.email = "12"
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterValidErrorCopy))
        self.validator.email = "1"
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterValidErrorCopy))
        self.validator.email = ""
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterAnythingErrorCopy))
        self.validator.email = nil
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterAnythingErrorCopy))
    }
    
    func testValidatingEmails() {
        self.validator.email = "test@test.com"
        XCTAssertEqual(self.validator.validationState, .valid)
        
        self.validator.email = "testtest.com"
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterValidErrorCopy))
        
        self.validator.email = "test @test.com"
        XCTAssertEqual(self.validator.validationState, .error(description: self.validator.pleaseEnterValidErrorCopy))
    }
}
