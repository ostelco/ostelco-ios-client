//
//  SettingsTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SettingsTableViewController2: UITableViewController {
    enum MenuItem: Int {
        case PurchaseHistory = 0
        case ChangeNickname = 1
        case TermsAndConditions = 2
        case PrivacyPolicy = 3
        case CancelMembership = 4
        case LogOut = 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.item) else {
            showAlert(title: "Error", msg: "Invalid selection")
            return
        }

        switch menuItem {
        case .PurchaseHistory:
            performSegue(withIdentifier: "purchaseHistory", sender: self)
        case .ChangeNickname:
            performSegue(withIdentifier: "nickname", sender: nil)
        case .TermsAndConditions:
            showAlert(title: "Open terms and conditions", msg: "")
        case .PrivacyPolicy:
            showAlert(title: "Open privacy policy", msg: "")
        case .CancelMembership:
            showDeleteAccountActionSheet()
        case .LogOut:
            showLogOutActionSheet()
        }
    }
}
