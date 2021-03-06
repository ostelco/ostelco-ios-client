//
//  LinkableTextTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest

class LinkableTextTests: XCTestCase {
    
    let dummyURL = URL(string: "https://google.com")!
    
    // MARK: - Generic linkable text
    
    private let testText = "She sells seashells by the seashore"
    
    func testNilPassedToInitializersWorks() {
        XCTAssertNotNil(LinkableText(fullText: testText, linkedBits: nil))
        XCTAssertNotNil(LinkableText(fullText: testText, linkedPortion: nil))
    }
    
    func testSingleLinkInitializerWorksWithIncludedText() {
        let linkedPortion = Link("seashells", url: dummyURL)
        
        guard let linkableText = LinkableText(fullText: testText, linkedPortion: linkedPortion) else {
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
        let linkedPortion = Link("sea monsters", url: dummyURL)
        XCTAssertNil(LinkableText(fullText: testText, linkedPortion: linkedPortion))
    }
    
    func testMultipleLinkInitializerWorksWithAllIncludedText() {
        let bits = [Link("seashells", url: dummyURL), Link("seashore", url: dummyURL)]
        
        guard let linkableText = LinkableText(fullText: testText, linkedBits: bits) else {
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
        let length = (testText as NSString).length
        let lastIndex = length - 1
        XCTAssertTrue(linkableText.isIndexLinked(lastIndex))
        XCTAssertEqual(linkableText.linkedText(at: lastIndex), bits[1])
        
        // Do we just get false and nil instead of IOOB'ing with a too long index?
        XCTAssertFalse(linkableText.isIndexLinked(length))
        XCTAssertNil(linkableText.linkedText(at: length))
    }
    
    func testMultipleLinkInitializerFailsWithSingleNotIncludedText() {
        let bits = [Link("seashells", url: dummyURL), Link("sea lion", url: dummyURL)]

        XCTAssertNil(LinkableText(fullText: testText, linkedBits: bits))
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
    
    func testLinkableLocationProblems() {
        for problem in LocationProblem.allCases {
            XCTAssertNotNil(problem.linkableCopy)
        }
    }
}
