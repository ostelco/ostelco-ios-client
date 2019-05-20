//
//  DidBecomeActiveHandling.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// A protocol to allow mix-in handling of `applicationDidBecomeActive` notifications
protocol DidBecomeActiveHandling: class {
    
    /// The NSNotificationCenter observer which is listening for `applicationDidBecomeActive` notifications
    var didBecomeActiveObserver: NSObjectProtocol? { get set }
    
    /// Called when the did become active NSNotification is received.
    func handleDidBecomeActive()
}

// MARK: - Default implementation

extension DidBecomeActiveHandling {
    
    func addDidBecomeActiveObserver() {
        self.didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.handleDidBecomeActive()
            })
    }
    
    func removeDidBecomeActiveObserver() {
        guard let removeMe = self.didBecomeActiveObserver else {
            // nothing to remove!
            return
        }
        
        NotificationCenter.default.removeObserver(removeMe)
        self.didBecomeActiveObserver = nil
    }
}
