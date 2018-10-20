//
//  SettingsTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import os
import SafariServices

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: replace row index with string identifier so you don't need to change both ui and code if you change the existing order of cells
        let rowIndex = (indexPath as NSIndexPath).row
        os_log("Row clicked: %{public}@", "\(rowIndex)")
        switch (rowIndex) {
        case 0:
            self.navigateToControllerByIdentifier(identifier: "profileTableVC")
            break
        case 1:
            self.openURL()
            break
        case 2:
            self.navigateToControllerByIdentifier(identifier: "purchaseHistoryVC")
            break
        case 3:
            self.logout()
        default:
            fatalError("Unhandled row index in settings static table view: \(rowIndex)")
        }
    }

    private func navigateToControllerByIdentifier(identifier: String) {
        os_log("Navigate to view controller with identifier: %{public}@", identifier)
        if let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) as? UIViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    
    private func openURL() {
        let safariVC = SFSafariViewController(url: URL(string: "https://docs.google.com/document/d/1sO6M79QeAbf6IJT3X06nRC-fBCnvssEWuYliYw4lyMU/edit?usp=sharing")!)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func logout() {
        os_log("Logout button clicked")
        sharedAuth.logout()
    }
}

