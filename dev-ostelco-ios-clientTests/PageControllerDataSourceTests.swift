//
//  PageControllerDataSourceTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import XCTest

class PageControllerDataSourceTests: XCTestCase {
    
    private lazy var pageController = UIPageViewController()
    
    private var lastUpdatedIndex: Int?
    
    private lazy var viewControllers = [
        UIViewController(),
        UIViewController(),
        UIViewController()
    ]
    
    private lazy var dataSource: PageControllerDataSource = {
        return PageControllerDataSource(pageController: self.pageController,
                                        viewControllers: self.viewControllers,
                                        pageIndicatorTintColor: .red,
                                        currentPageIndicatorTintColor: .green,
                                        delegate: self)
    }()
    
    override func tearDown() {
        self.lastUpdatedIndex = nil
        super.tearDown()
    }
    
    func testOrdering() {
        XCTAssertEqual(self.dataSource.presentationCount(for: self.pageController), 3)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 0)
        
        let vc1 = self.viewControllers[0]
        let vc2 = self.viewControllers[1]
        let vc3 = self.viewControllers[2]
        
        XCTAssertNil(self.dataSource.pageViewController(self.pageController, viewControllerBefore: vc1))
        
        guard let after1 = self.dataSource.pageViewController(self.pageController, viewControllerAfter: vc1) else {
            XCTFail("Couldn't get VC after VC 1")
            return
        }
        XCTAssertEqual(after1, vc2)
        
        guard let before2 = self.dataSource.pageViewController(self.pageController, viewControllerBefore: vc2) else {
            XCTFail("Couldn't get VC before vc2")
            return
        }
        
        XCTAssertEqual(before2, vc1)
        
        guard let after2 = self.dataSource.pageViewController(self.pageController, viewControllerAfter: vc2) else {
            XCTFail("Couldn't get VC after vc 2!")
            return
        }
        
        XCTAssertEqual(after2, vc3)
        
        guard let before3 = self.dataSource.pageViewController(self.pageController, viewControllerBefore: vc3) else {
            XCTFail("Couldn't get vc before vc3!")
            return
        }
        
        XCTAssertEqual(before3, vc2)
        
        XCTAssertNil(self.dataSource.pageViewController(self.pageController, viewControllerAfter: vc3))
    }
    
    func testProgramaticallyMovingForwardThroughPagesDoesNotExceedArrayLength() {
        // We should start at zero
        XCTAssertEqual(self.dataSource.currentIndex, 0)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 0)

        self.dataSource.goToNextPage(animated: false)
        XCTAssertEqual(self.lastUpdatedIndex, 1)
        XCTAssertEqual(self.dataSource.currentIndex, 1)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 1)

        self.dataSource.goToNextPage(animated: false)
        XCTAssertEqual(self.lastUpdatedIndex, 2)
        XCTAssertEqual(self.dataSource.currentIndex, 2)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 2)
        
        self.lastUpdatedIndex = nil
        
        // We should not advance past the number of pages or get a delegate callback
        self.dataSource.goToNextPage(animated: false)
        XCTAssertNil(self.lastUpdatedIndex)
        XCTAssertEqual(self.dataSource.currentIndex, 2)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 2)
    }
    
    func testProgramaticallyMovingBackwardThroughPagesDoesNotGoPastZero() {
        // Page forward to get to the last page
        self.dataSource.goToNextPage(animated: false)
        self.dataSource.goToNextPage(animated: false)
        
        XCTAssertEqual(self.lastUpdatedIndex, 2)
        XCTAssertEqual(self.dataSource.currentIndex, 2)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 2)

        self.dataSource.goToPreviousPage(animated: false)
        XCTAssertEqual(self.lastUpdatedIndex, 1)
        XCTAssertEqual(self.dataSource.currentIndex, 1)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 1)

        self.dataSource.goToPreviousPage(animated: false)
        XCTAssertEqual(self.lastUpdatedIndex, 0)
        XCTAssertEqual(self.dataSource.currentIndex, 0)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 0)
        
        self.lastUpdatedIndex = nil
        
        // This should not update the last updated index or call the delegate
        self.dataSource.goToPreviousPage(animated: false)
        XCTAssertNil(self.lastUpdatedIndex)
        XCTAssertEqual(self.dataSource.currentIndex, 0)
        XCTAssertEqual(self.dataSource.presentationIndex(for: self.pageController), 0)
    }
}

extension PageControllerDataSourceTests: PageControllerDataSourceDelegate {
    
    func pageChanged(to index: Int) {
        self.lastUpdatedIndex = index
    }
}
