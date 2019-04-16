//
//  CountryDataSource.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

class CountryDataSource: GenericTableViewDataSource<Country, CountryCell> {
    
    var selectedCountry: Country? {
        didSet {
            self.reloadData()
        }
    }
    
    override func configureCell(_ cell: CountryCell, for country: Country) {
        cell.countryLabel.text = country.name
        if country == self.selectedCountry {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    override func selectedItem(_ country: Country) {
        self.selectedCountry = country
    }
}
