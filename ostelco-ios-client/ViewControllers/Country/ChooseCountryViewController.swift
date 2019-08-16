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
        return CountryDataSource(
            tableView: tableView,
            countries: Country.defaultCountries,
            delegate: self
        )
    }()
    
    weak var delegate: ChooseCountryDelegate?
    private var currentSelectedCountry: Country? {
        didSet {
            if currentSelectedCountry == nil {
                continueButton.isEnabled = false
            } else {
                continueButton.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tintColor = OstelcoColor.oyaBlue.toUIColor
        tableView.addEmptyFooter()
        dataSource.reloadData()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard let country = currentSelectedCountry else {
            return
        }
        
        showSpinner()
        OstelcoAnalytics.logEvent(.ChosenCountry(country: country))
        delegate?.selectedCountry(country)
    }
}

extension ChooseCountryViewController: CountrySelectionDelegate {
    
    func selected(country: Country) {
        currentSelectedCountry = country
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
