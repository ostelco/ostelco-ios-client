//
//  UIApplicaiton+Testing.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// Are UI tests being run?
    static var isUITesting: Bool {
        // TODO: Update this once UI tests are set up
        return false
    }
    
    /// Are any tests whatsoever being run?
    static var isTesting: Bool {
        return NSClassFromString("XCTestCase") != nil
    }
    
    /// Are non-UI tests being run? 
    static var isNonUITesting: Bool {
        return self.isTesting && !self.isUITesting
    }
}
