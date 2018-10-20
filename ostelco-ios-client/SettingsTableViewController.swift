//
//  SettingsTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import os

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: replace row index with string identifier so you don't need to change both ui and code if you change the existing order of cells
        let rowIndex = (indexPath as NSIndexPath).row
        switch (rowIndex) {
        case 0:
        // TODO: open personal details
            break
        case 1:
        // TODO: open terms and conditions
            break
        case 2:
        // TODO: open purchase history
            break
        case 3:
            self.logout()
        default:
            fatalError("Unhandled row index in settings static table view: \(rowIndex)")
        }
    }

    func logout() {
        os_log("Logout button clicked")
        sharedAuth.logout()
    }
}

