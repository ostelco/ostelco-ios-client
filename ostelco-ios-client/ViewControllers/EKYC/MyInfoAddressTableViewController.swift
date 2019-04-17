//
//  MyInfoAddressTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class MyInfoAddressTableViewController: UITableViewController {
    var myInfoDetails: MyInfoDetails?

    @IBOutlet private weak var street: UITextField!
    @IBOutlet private weak var city: UITextField!
    @IBOutlet private weak var unit: UITextField!
    @IBOutlet private weak var postal: UITextField!
    @IBOutlet private weak var country: UITextField!

    var updateDelegate: MyInfoDetailsUpdate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        updateUI(myInfoDetails)
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true) {
            print("Done cancelling the edit")
        }
    }
    
    @IBAction private func save(_ sender: Any) {
        dismiss(animated: true) {
            print("Done saving the edit")
        }
    }

    func updateUI(_ myInfoDetails: MyInfoDetails?) {
        guard let myInfoDetails = myInfoDetails else {
            return
        }
        let address = myInfoDetails.address
        if let street = address.street {
            self.street.text = street
        }
        if let unit = address.unit {
            self.unit.text = unit
        }
        if let postal = address.postal {
            self.postal.text = postal
        }
        if let country = address.country {
            self.country.text = country
        }
    }
}

protocol MyInfoDetailsUpdate {
    func handleUpdate(myInfoDetails: MyInfoDetails)
}
