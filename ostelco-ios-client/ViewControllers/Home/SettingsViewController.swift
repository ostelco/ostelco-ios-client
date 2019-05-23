//
//  SettingsViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 23/05/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet private weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var appVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = "App Version \(version)"
        }
        if let buildNumber = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
            appVersion = "\(appVersion) Build \(buildNumber)"
        }
        self.versionLabel.text = appVersion
    }
}
