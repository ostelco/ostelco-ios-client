//
//  InternetConnectionParentViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 6/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class InternetConnectionParentViewController: UIViewController, InternetConnectionMonitorDelegate {
    
    private lazy var monitor: InternetConnectionMonitor = {
        return InternetConnectionMonitor(delegate: self)
    }()
    
    var workingChild: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor.start()
    }
    
    func connectionChanged(_ connection: Connection) {
        switch connection {
        case .connected:
            if let workingChild = workingChild {
                embedFullViewChild(workingChild)
                self.workingChild = nil
            }
        case .disconnected:
            self.workingChild = self.children.first
            
            let noInternet = OhNoViewController.fromStoryboard(type: .noInternet)
            embedFullViewChild(noInternet)
        }
    }
}
