//
//  SettingsTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SettingsTableViewController2: UITableViewController {
    override func viewDidLoad() {
        // super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.isUserInteractionEnabled = true
        self.tableView.allowsSelection = true
    }
    
    enum MenuItem: Int {
        case PurchaseHistory = 0
        case ChangeNickname = 1
        case TermsAndConditions = 2
        case PrivacyPolicy = 3
        case CancelMembership = 4
        case LogOut = 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.item) else {
            showAlert(title: "Error", msg: "Invalid selection")
            return
        }

        switch menuItem {
            case .PurchaseHistory:
                print("purchase history")
            case .ChangeNickname:
                print("nickname")
            case .TermsAndConditions:
                print("terms")
            case .PrivacyPolicy:
                print("policy")
            case .CancelMembership:
                print("membership")
            case .LogOut:
                print("log out")
        }
    }
}
