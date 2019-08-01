//
//  RootCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import ostelco_core
@testable import Oya_Development_app
import XCTest
import PromiseKit

class OnboardingCoordinatorTests: XCTestCase {
    
    enum Errors: Error {
        case noContextFound
    }
    
    class FakeNavigation: UINavigationController {
        var trappedControllers = [UIViewController]()
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            trappedControllers.append(viewController)
        }
        
        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            trappedControllers.append(contentsOf: viewControllers)
        }
    }
    
    class FakeTokenProvider: TokenProvider {
        func getToken() -> Promise<String> {
            return Promise.value("xxxx")
        }
        
        func forceRefreshToken() -> Promise<String> {
            return Promise.value("xxxx")
        }
    }
    
    class FakePrimeAPI: PrimeAPI {
        var fakeContext: ContextQuery.Data.Customer?
        
        convenience init() {
            
            self.init(baseURLString: "https://google.com", tokenProvider: FakeTokenProvider())
        }
        
        override func loadContext() -> Promise<ContextQuery.Data.Customer> {
            if let context = fakeContext {
                return Promise.value(context)
            }
            return Promise(error: Errors.noContextFound)
        }
    }
    
    func testCoordinatorHandlesUseSeeingLoginCarousel() {
        let fake = FakeNavigation()
        let fakePrime = FakePrimeAPI()
        let testCoordinator = OnboardingCoordinator(navigationController: fake, primeAPI: fakePrime)
        
        testCoordinator.loginCarouselSeen()
        
        AssertAllAreClass(fake.trappedControllers, aClass: EmailEntryViewController.self)
    }
    
    func AssertAllAreClass(_ items: [NSObject], aClass: AnyClass, file: StaticString = #file, line: UInt = #line) {
        XCTAssert(items.allSatisfy({ $0.isKind(of: aClass) }), file: file, line: line)
    }
}
