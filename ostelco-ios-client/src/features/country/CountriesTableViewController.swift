//
//  CountriesTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

fileprivate let countryCodes = ["DE", "IE", "NO", "SG", "SE", "GB", "US"]

class CountriesTableViewController: UITableViewController {

    @IBOutlet weak var selectedCountryLabel: UILabel!
    let countries: [Country] = countryCodes.map { Country($0) }

    override func viewDidLoad() {
        selectedCountryLabel.text = OnBoardingManager.sharedInstance.selectedCountry.name!
        self.tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCountryListActionSheet(countries: countries, completion: {
            self.selectedCountryLabel.text = OnBoardingManager.sharedInstance.selectedCountry.name!
        })
    }
}
