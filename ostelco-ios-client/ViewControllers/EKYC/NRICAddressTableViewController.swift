//
//  NRICAddressTableViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Crashlytics

class NRICAddressTableViewController: UITableViewController {
    @IBOutlet private weak var street: UITextField!
    @IBOutlet private weak var house: UITextField!
    @IBOutlet private weak var city: UITextField!
    @IBOutlet private weak var postcode: UITextField!
    @IBOutlet private weak var country: UITextField!
    var spinnerView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
  
  @IBAction private func `continue`(_ sender: Any) {
    if validateAddress() == false {
      let alert = UIAlertController(
        title: "Enter valid address",
        message: "Ensure that you have entered all fields",
        preferredStyle: UIAlertController.Style.alert
      )
      alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    } else {
        spinnerView = showSpinner(onView: self.view)
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        APIManager.sharedInstance.regions.child(countryCode).child("kyc/profile")
            .withParam("address", self.buildAddressString())
            .withParam("phoneNumber", "12345678")
        .request(.put)
        .onSuccess { data in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "waitForDocs", sender: self)
            }
        }
        .onFailure { requestError in
            do {
                guard let errorData = requestError.entity?.content as? Data else {
                    throw APIManager.APIError.errorCameWithoutData
                }

                let putProfileError = try JSONDecoder().decode(PutProfileError.self, from: errorData)
                self.showAlert(title: "Error", msg: "\(putProfileError.errors)")
            } catch let error {
                print(error)
                Crashlytics.sharedInstance().recordError(requestError)
                self.showAPIError(error: requestError)
            }
            
        }
        .onCompletion { _ in
            self.removeSpinner(self.spinnerView)
        }
    }
    }

  private func validateAddress() -> Bool {
    if
      let street = street.text, !street.isEmpty,
      let house = house.text, !house.isEmpty,
      let city = city.text, !city.isEmpty,
      let postcode = postcode.text, !postcode.isEmpty,
        let country = country.text, !country.isEmpty {
        return true
    }
    return false
  }
    
    private func buildAddressString() -> String? {
        if validateAddress() {
            guard
                let street = street.text,
                let house = house.text,
                let city = city.text,
                let postcode = postcode.text,
                let country = country.text else {
                    fatalError("Somehow validation passed but one of these was null")
            }
            
            return "\(street);;;\(house);;;\(city);;;\(postcode);;;\(country)"
        }
        return nil
    }
}
