//
//  InternetConnectionManager.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/31/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Network

class InternetConnectionMonitor {
    static let shared = InternetConnectionMonitor()
    
    private let monitor = NWPathMonitor()
    
    private init() {
        self.monitor.pathUpdateHandler = self.handleUpdatedPath
    }
    
    func start() {
        let bg = DispatchQueue.global(qos: .background)
        self.monitor.start(queue: bg)
    }
    
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
    
    deinit {
        self.monitor.cancel()
    }
    
    private func handleUpdatedPath(_ path: NWPath) {
        DispatchQueue.main.async {
            let coordinator = UIApplication.shared.typedDelegate.rootCoordinator
            switch path.status {
            case .satisfied:
                coordinator.hideNoInternet()
            case .unsatisfied,
                 .requiresConnection:
                coordinator.showNoInternet()
            @unknown default:
                ApplicationErrors.assertAndLog("Apple added something else here you need to handle!")
            }
        }
    }
}
