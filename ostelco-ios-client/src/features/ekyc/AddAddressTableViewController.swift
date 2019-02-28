//
//  AddAddressTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class AddAddressTableViewController: UITableViewController {
  @IBOutlet weak var street: UITextField!
  @IBOutlet weak var house: UITextField!
  @IBOutlet weak var city: UITextField!
  @IBOutlet weak var postcode: UITextField!
  @IBOutlet weak var country: UITextField!


  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  @IBAction func `continue`(_ sender: Any) {
    if (validateAddress() == false) {
      let alert = UIAlertController(
        title: "Enter valid address",
        message: "Ensure that you have entered all fields",
        preferredStyle: UIAlertController.Style.alert
      )
      alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    } else {
      performSegue(withIdentifier: "waitForDocs", sender: self)
//      dismiss(animated: true) {
//        print("Continue with the new Address")
//      }
    }
  }

  private func validateAddress() -> Bool {
    guard
      let _ = street.text,
      let _ = house.text,
      let _ = city.text,
      let _ = postcode.text,
      let _ = country.text
      else {
        return false
    }
    return true
  }

}
