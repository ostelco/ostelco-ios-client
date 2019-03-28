//
//  CountriesTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CountriesTableViewController: UITableViewController {
    
    @IBOutlet weak var selectedCountryLabel: UILabel!
    let countries: [Country] = {
        var countries: [Country] = []
        countries.append(Country(countryCode: "DE"))
        countries.append(Country(countryCode: "IE"))
        countries.append(Country(countryCode: "NO"))
        countries.append(Country(countryCode: "SG"))
        countries.append(Country(countryCode: "SE"))
        countries.append(Country(countryCode: "GB"))
        countries.append(Country(countryCode: "US"))
        return countries
    }()
    
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

