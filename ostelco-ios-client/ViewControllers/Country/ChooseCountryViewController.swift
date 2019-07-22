//
//  ChooseCountryViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import ostelco_core
import UIKit

protocol ChooseCountryDelegate: class {
    func selectedCountry(_ country: Country)
}

class ChooseCountryViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var continueButton: UIButton!
    
    private lazy var dataSource: CountryDataSource = {
        return CountryDataSource(tableView: self.tableView,
                                 countries: Country.defaultCountries,
                                 delegate: self)
    }()
    
    weak var delegate: ChooseCountryDelegate?
    private var currentSelectedCountry: Country? {
        didSet {
            if self.currentSelectedCountry == nil {
                self.continueButton.isEnabled = false
            } else {
                self.continueButton.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tintColor = OstelcoColor.oyaBlue.toUIColor
        self.tableView.addEmptyFooter()
        self.dataSource.reloadData()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let country = self.currentSelectedCountry else {
            return
        }
        
        showSpinner(onView: self.view)
        delegate?.selectedCountry(country)
    }
}

extension ChooseCountryViewController: CountrySelectionDelegate {
    
    func selected(country: Country) {
        self.currentSelectedCountry = country
    }
}

extension ChooseCountryViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .country
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
