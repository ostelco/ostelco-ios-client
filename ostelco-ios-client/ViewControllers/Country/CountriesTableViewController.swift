//
//  CountriesTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class CountriesTableViewController: UITableViewController {
    
    private lazy var dataSource: CountryDataSource = {
        return CountryDataSource(tableView: self.tableView,
                                 items: Country.defaultCountries)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addEmptyFooter()
        self.dataSource.selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
    }
}
