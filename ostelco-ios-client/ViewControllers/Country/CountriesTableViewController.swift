//
//  CountriesTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

class CountriesTableViewController: UITableViewController {
    
    private lazy var dataSource: CountryDataSource = {
        return CountryDataSource(tableView: self.tableView,
                                 countries: Country.defaultCountries,
                                 delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = OstelcoColor.oyaBlue.toUIColor
        self.tableView.addEmptyFooter()
        self.dataSource.selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
    }
}

extension CountriesTableViewController: CountrySelectionDelegate {
    
    func selected(country: Country) {
        OnBoardingManager.sharedInstance.selectedCountry = country
        OstelcoAnalytics.logEvent(.ChosenCountry(country: OnBoardingManager.sharedInstance.selectedCountry))
    }
}
