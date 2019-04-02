//
//  PendingVerificationViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class PendingVerificationViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  @IBAction func `continue`(_ sender: Any) {
    let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
    APIManager.sharedInstance.regions.child(countryCode).load()
        .onSuccess { data in
            if let regionResponse: RegionResponse = data.typedContent(ifNone: nil) {
                // if let regionRespons.kycStatusMap.NR
                // TODO: Convert status to enum
                if regionResponse.status == .APPROVED {
                    self.performSegue(withIdentifier: "ESim", sender: self)
                } else {
                    if let status = regionResponse.kycStatusMap.JUMIO {
                        self.showAlert(title: "Status", msg: status.rawValue)
                    } else {
                        self.showAlert(title: "Status", msg: regionResponse.status.rawValue)
                    }
                }
              } else {
                  // TODO: Create more descriptive error. Not sure if this cause ever will happen, but that doesn't mean we shouldn't handle it somehow.
                  self.showAlert(title: "Error", msg: "Failed to parse user from server response.")
              }
            }
            .onFailure { error in
                self.showAPIError(error: error)
        }
        .onFailure { error in
            self.showAPIError(error: error)
    }
  }
}
