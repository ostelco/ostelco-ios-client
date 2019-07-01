//
//  InternetConnectionManager.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Network

/// A class to monitor the internet connection status.
/// NOTE: This works great on device, but if you try to test
///       on the simulator by toggling your computer wifi off
///       and on, it'll detect the connection going off but not
///       going back on. TODO: File a Radar.

enum Connection {
    case connected
    case disconnected
}

protocol InternetConnectionMonitorDelegate: class {
    func connectionChanged(_ connection: Connection)
}

class InternetConnectionMonitor {
    weak var delegate: InternetConnectionMonitorDelegate?
    
    private let monitor = NWPathMonitor()
    
    init(delegate: InternetConnectionMonitorDelegate) {
        self.monitor.pathUpdateHandler = self.handleUpdatedPath
        self.delegate = delegate
    }
    
    deinit {
        self.monitor.cancel()
    }
    
    /// Start monitoring the network connection asynchronously
    func start() {
        let bg = DispatchQueue.global(qos: .background)
        self.monitor.start(queue: bg)
    }
    
    /// Checks if the current path is connected synchronously
    ///
    /// - Returns: True if connected, false if not.
    func isCurrentlyConnected() -> Bool {
        switch self.monitor.currentPath.status {
        case .satisfied:
            return true
        case .requiresConnection,
             .unsatisfied:
            return false
        @unknown default:
            ApplicationErrors.assertAndLog("Apple added something else here you need to handle!")
            return false
        }
    }
    
    private func handleUpdatedPath(_ path: NWPath) {
        DispatchQueue.main.async {
            switch path.status {
            case .satisfied:
                self.delegate?.connectionChanged(.connected)
            case .unsatisfied, .requiresConnection:
                self.delegate?.connectionChanged(.disconnected)
            @unknown default:
                ApplicationErrors.assertAndLog("Apple added something else here you need to handle!")
            }
        }
    }
}
