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
        embedSwiftUI(SettingsView().environmentObject(SettingsStore(controller: TabBarViewController())))
    }
}
