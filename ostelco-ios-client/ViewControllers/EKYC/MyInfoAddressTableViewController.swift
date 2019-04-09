//
//  MyInfoAddressTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class MyInfoAddressTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true) {
            print("Done cancelling the edit")
        }
    }
    @IBAction func save(_ sender: Any) {
        dismiss(animated: true) {
            print("Done saving the edit")
        }
    }
}
