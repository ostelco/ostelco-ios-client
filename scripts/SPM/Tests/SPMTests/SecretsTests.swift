//
//  SecretsTests.swift
//  SPMTests
//
//  Created by Ellen Shapiro on 4/9/19.
//

import Files
import XCTest
@testable import Core

class SecretsTests: XCTestCase {
    
    private lazy var testSourceRoot: Folder = {
        let env = ProcessInfo.processInfo.environment
        guard let testRoot = env["TEST_ROOT"] else {
            fatalError("No test root provided! Please add this to the environment variables for the scheme you are using.")
        }
        
        return try! Folder(path: testRoot)
    }()
    
    func testAuth0NotIncludingAllKeysFails() {
        let secrets = [
            Auth0Updater.JSONKeyToUpdate.clientID.rawValue: "TEST",
        ]
        
        do {
            try Auth0Updater.run(secrets: secrets, sourceRoot: self.testSourceRoot)
        } catch Secrets.Error.missingSecrets(let keyNames) {
            XCTAssertEqual(keyNames.count, Auth0Updater.JSONKeyToUpdate.allCases.count - 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAuth0IncludingAllKeysSucceeds() {
        var secrets = [String: String]()
        for (index, key) in Auth0Updater.JSONKeyToUpdate.allCases.enumerated() {
            secrets[key.rawValue] = "Test\(index)"
        }
        
        XCTAssertNoThrow(try Auth0Updater.run(secrets: secrets, sourceRoot: self.testSourceRoot))
        
        // TODO: Reload
        
        
    }

    static var allTests = [
        ("testAuth0NotIncludingAllKeysFails", testAuth0NotIncludingAllKeysFails),
        ("testAuth0IncludingAllKeysSucceeds", testAuth0IncludingAllKeysSucceeds),
    ]
}
