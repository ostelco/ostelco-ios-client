//
//  RootCoordinatorTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import XCTest
import PromiseKit
import FirebaseAuth
import CoreLocation

class OnboardingCoordinatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        UserManager.shared.customer = nil
    }
    
    enum Errors: Error {
        case noContextFound
    }
    
    class FakeNavigation: UINavigationController {
        var trappedControllers = [UIViewController]()
        var expectation = XCTestExpectation(description: "navigation")
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            trappedControllers.append(viewController)
            expectation.fulfill()
        }
        
        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            trappedControllers.append(contentsOf: viewControllers)
            expectation.fulfill()
        }
    }
    
    struct FakeAuth: Authorization {
        func removeStateDidChangeListener(_ listenerHandle: AuthStateDidChangeListenerHandle) {
            return
        }
        
        class FakeHandle: NSObject {
            
        }
        
        func addStateDidChangeListener(_ listener: @escaping AuthStateDidChangeListenerBlock) -> AuthStateDidChangeListenerHandle {
            return FakeHandle()
        }
        
        
    }
    
    class FakeDelegate: OnboardingCoordinatorDelegate {
        let expectation = XCTestExpectation(description: "compelted onboarding")
        
        func onboardingComplete() {
            expectation.fulfill()
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
        var fakeContext: PrimeGQL.ContextQuery.Data.Context?
        
        convenience init() {
            
            self.init(baseURLString: "https://google.com", tokenProvider: FakeTokenProvider())
        }
        
        override func loadContext() -> Promise<PrimeGQL.ContextQuery.Data.Context> {
            if let context = fakeContext {
                return Promise.value(context)
            }
            return Promise(error: Errors.noContextFound)
        }
    }
    
    class FakeNotifications: PushNotificationController {
        override func getAuthorizationStatus() -> Promise<UNAuthorizationStatus> {
            return .value(.notDetermined)
        }
        
        override func checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: Bool) -> Promise<Bool> {
            return .value(true)
        }
    }
    
    class FakeLocation: LocationController {
        let locationEnabled: Bool
        
        init(locationEnabled: Bool) {
            self.locationEnabled = locationEnabled
        }
        
        override var authorizationStatus: CLAuthorizationStatus {
            get {
                if locationEnabled {
                    return .authorizedAlways
                } else {
                    return .notDetermined
                }
            }
        }
    }
    
    let navigationTimeout = 3.0

    func AssertAllAreClass(_ items: [NSObject], aClass: AnyClass, file: StaticString = #file, line: UInt = #line) {
        XCTAssert(items.allSatisfy({ $0.isKind(of: aClass) }), file: file, line: line)
    }
    
    func testCoordinatorHandlesLocationProblemsAndResolvingThem() {
        let navigation = FakeNavigation()
        let api = FakePrimeAPI()
        
        let coordinator = OnboardingCoordinator(navigationController: navigation, primeAPI: api)
        coordinator.handleLocationProblem(LocationProblem.authorizedButWrongCountry(expected: "xxx", actual: "yyy"))
        
        wait(for: [navigation.expectation], timeout: navigationTimeout)
        
        XCTAssert(navigation.trappedControllers.last is LocationProblemViewController)
        
        navigation.expectation = XCTestExpectation(description: "navigation again")
        
        coordinator.retry()
        
        wait(for: [navigation.expectation], timeout: navigationTimeout)
        
        XCTAssertFalse(navigation.trappedControllers.last is LocationProblemViewController)
    }
    
    func testCoordinatorHandlesAcceptingPermissions() {
        let navigation = FakeNavigation()
        let api = FakePrimeAPI()
        let auth = FakeAuth()
        let location = FakeLocation(locationEnabled: true)
        
        api.fakeContext = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxx", analyticsId: "xxx", referralId: "xxx"),
            regions: [RegionResponse]()
        ).toGraphQLModel()
        
        let coordinator = OnboardingCoordinator(
            navigationController: navigation,
            primeAPI: api,
            notifications: FakeNotifications(),
            auth: auth,
            location: location
        )
        coordinator.localContext = OnboardingContext(hasFirebaseToken: true, hasAgreedToTerms: true)
        
        coordinator.locationUsageAuthorized()
        
        wait(for: [navigation.expectation], timeout: navigationTimeout)
        
        XCTAssert(navigation.trappedControllers.last is EnableNotificationsViewController)
    }
    
    func testCoordinatorHandlesAcceptingTerms() {
        let navigation = FakeNavigation()
        let api = FakePrimeAPI()
        let auth = FakeAuth()
        
        let coordinator = OnboardingCoordinator(navigationController: navigation, primeAPI: api, auth: auth)
        coordinator.localContext = OnboardingContext(hasFirebaseToken: true)
        
        coordinator.legaleseAgreed()
        
        wait(for: [navigation.expectation], timeout: navigationTimeout)
        
        XCTAssert(navigation.trappedControllers.last is GetStartedViewController)
    }
    
    func testCoordinatorHandlesAcceptingLastPermissions() {
        let navigation = FakeNavigation()
        let api = FakePrimeAPI()
        let auth = FakeAuth()
        let notifications = FakeNotifications()
        
        api.fakeContext = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxx", analyticsId: "xxx", referralId: "xxx"),
            regions: [RegionResponse]()
        ).toGraphQLModel()
        
        let delegate = FakeDelegate()
       
        let coordinator = OnboardingCoordinator(
            navigationController: navigation,
            primeAPI: api,
            notifications: notifications,
            auth: auth,
            location: FakeLocation(locationEnabled: true)
        )
        coordinator.delegate = delegate
        coordinator.localContext = OnboardingContext(hasFirebaseToken: true, hasAgreedToTerms: true)
        coordinator.localContext.hasSeenNotificationPermissions = true
        
        coordinator.requestPermission()
        
        wait(for: [delegate.expectation], timeout: navigationTimeout)
    }
}
