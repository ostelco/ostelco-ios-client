//
//  LinkableTextTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import OstelcoStyles
import XCTest

class LinkableTextTests: XCTestCase {
    
    // MARK: - Generic linkable text
    
    private let testText = "She sells seashells by the seashore"
    
    func testNilPassedToInitializersWorks() {
        XCTAssertNotNil(LinkableText(fullText: self.testText, linkedBits: nil))
        XCTAssertNotNil(LinkableText(fullText: self.testText, linkedPortion: nil))
    }
    
    func testSingleLinkInitializerWorksWithIncludedText() {
        let linkedPortion = "seashells"
        
        guard let linkableText = LinkableText(fullText: self.testText, linkedPortion: linkedPortion) else {
            XCTFail("This should have worked!")
            return
        }
        
        // Link should start at the beginning of the word
        XCTAssertFalse(linkableText.isIndexLinked(9))
        XCTAssertNil(linkableText.linkedText(at: 9))
        XCTAssertTrue(linkableText.isIndexLinked(10))
        XCTAssertEqual(linkableText.linkedText(at: 10), linkedPortion)
        
        // Link should end at the end of the word.
        XCTAssertTrue(linkableText.isIndexLinked(18))
        XCTAssertEqual(linkableText.linkedText(at: 18), linkedPortion)
        XCTAssertFalse(linkableText.isIndexLinked(19))
        XCTAssertNil(linkableText.linkedText(at: 19))
    }
    
    func testSingleLinkInitializerFailsWithNotIncludedText() {
        let linkedPortion = "sea monsters"
        XCTAssertNil(LinkableText(fullText: self.testText, linkedPortion: linkedPortion))
    }
    
    func testMultipleLinkInitializerWorksWithAllIncludedText() {
        let bits = ["seashells", "seashore"]
        
        guard let linkableText = LinkableText(fullText: self.testText, linkedBits: bits) else {
            XCTFail("Both of these are contained, this should have worked!")
            return
        }
        
        // First link should start at the beginning of the first word
        XCTAssertFalse(linkableText.isIndexLinked(9))
        XCTAssertNil(linkableText.linkedText(at: 9))
        XCTAssertTrue(linkableText.isIndexLinked(10))
        XCTAssertEqual(linkableText.linkedText(at: 10), bits[0])
        
        // First link should end at the end of the first word.
        XCTAssertTrue(linkableText.isIndexLinked(18))
        XCTAssertEqual(linkableText.linkedText(at: 18), bits[0])
        XCTAssertFalse(linkableText.isIndexLinked(19))
        XCTAssertNil(linkableText.linkedText(at: 19))
        
        // Second link should start at the beginning of the second word
        XCTAssertFalse(linkableText.isIndexLinked(26))
        XCTAssertNil(linkableText.linkedText(at: 26))
        XCTAssertTrue(linkableText.isIndexLinked(27))
        XCTAssertEqual(linkableText.linkedText(at: 27), bits[1])
        
        // Second link should end at the end of the word
        let length = (self.testText as NSString).length
        let lastIndex = length - 1
        XCTAssertTrue(linkableText.isIndexLinked(lastIndex))
        XCTAssertEqual(linkableText.linkedText(at: lastIndex), bits[1])
        
        // Do we just get false and nil instead of IOOB'ing with a too long index?
        XCTAssertFalse(linkableText.isIndexLinked(length))
        XCTAssertNil(linkableText.linkedText(at: length))
    }
    
    func testMultipleLinkInitializerFailsWithSingleNotIncludedText() {
        let bits = ["seashells", "sea lion"]

        XCTAssertNil(LinkableText(fullText: self.testText, linkedBits: bits))
    }
    
    // MARK: - Individual instances of linkable text
    
    func testLinkableTextInOnboardingInstantiates() {
        for page in OnboardingPage.allCases {
            XCTAssertNotNil(page.linkableText)
        }
    }
    
    func testLinkableTextInLegalLinksInstantiates() {
        for link in LegalLink.allCases {
            XCTAssertNotNil(link.linkableText)
        }
    }
    
    func testLinkableTextGenerationForLocationRequirement() {
        let vc = AllowLocationAccessViewController.fromStoryboard()
        for country in Country.defaultCountries {
            XCTAssertNotNil(vc.generateLinkableText(for: country),
                            "Could not generate linkable text for \(country.nameOrPlaceholder)")
        }
    }
    
    func testLinkableLocationProblems() {
        for problem in LocationProblem.allCases {
            XCTAssertNotNil(problem.linkableCopy)
        }
    }
}
