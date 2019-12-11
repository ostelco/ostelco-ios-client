//// Created for ostelco-ios-client in 2019

import XCTest
import Netverify
@testable import Oya_Development_app

class JumioCoordinatorTests: XCTestCase {
    
    class FakeDelegate: JumioCoordinatorDelegate {
        var didSucceed = false
        var didCancel = false
        var didFail = false
        
        func scanSucceeded(scanID: String) {
            didSucceed = true
        }
        
        func scanCancelled() {
            didCancel = true
        }
        
        func scanFailed(errorMessage: String) {
            didFail = true
        }
    }
    
    class FakeError: NetverifyError {
        var fakeCode: String!
        
        override var code: String! {
            get {
                return fakeCode
            }
            set(value) {
                self.fakeCode = value
            }
        }        
    }

    func testJumioCoordinatorRelaysFinish() throws {
        let coordinator = try JumioCoordinator(regionID: "xxx", primeAPI: mockAPI, targetCountry: Country("xxx"))
        let fakeDelegate = FakeDelegate()
        coordinator.delegate = fakeDelegate
        
        coordinator.netverifyViewController(NetverifyViewController(), didFinishWith: NetverifyDocumentData(), scanReference: "xxx")
        
        XCTAssert(fakeDelegate.didSucceed)
        XCTAssertFalse(fakeDelegate.didFail)
        XCTAssertFalse(fakeDelegate.didCancel)
    }
    
    func testJumioCoordinatorIgnoresErrorWhenUserJustCancels() throws {
        let coordinator = try JumioCoordinator(regionID: "xxx", primeAPI: mockAPI, targetCountry: Country("xxx"))
        let fakeDelegate = FakeDelegate()
        coordinator.delegate = fakeDelegate
        
        let error = FakeError()
        error.code = "G00000"
        
        coordinator.netverifyViewController(NetverifyViewController(), didCancelWithError: error, scanReference: "xxx")
        
        XCTAssertFalse(fakeDelegate.didSucceed)
        XCTAssertFalse(fakeDelegate.didFail)
        XCTAssert(fakeDelegate.didCancel)
    }

    func testJumioCoordinatorRelaysErrors() throws {
        let coordinator = try JumioCoordinator(regionID: "xxx", primeAPI: mockAPI, targetCountry: Country("xxx"))
        let fakeDelegate = FakeDelegate()
        coordinator.delegate = fakeDelegate
        
        let error = FakeError()
        error.code = "xxxx"
        
        coordinator.netverifyViewController(NetverifyViewController(), didCancelWithError: error, scanReference: "xxx")
        
        XCTAssertFalse(fakeDelegate.didSucceed)
        XCTAssert(fakeDelegate.didFail)
        XCTAssertFalse(fakeDelegate.didCancel)
    }
}
