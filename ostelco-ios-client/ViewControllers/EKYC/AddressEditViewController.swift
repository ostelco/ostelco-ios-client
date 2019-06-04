//
//  AddressEditViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import ostelco_core
import PromiseKit
import UIKit

protocol MyInfoAddressUpdateDelegate: class {
    func addressUpdated(to address: MyInfoAddress)
}

class AddressEditViewController: UITableViewController {
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var saveBarButtton: UIBarButtonItem!
    @IBOutlet private var cancelBarButton: UIBarButtonItem!
    
    var spinnerView: UIView?
    
    enum Mode {
        case nricEdit
        case myInfoVerify(myInfo: MyInfoAddress?)
        
        var sections: [AddressEditSection] {
            switch self {
            case .nricEdit:
                return AddressEditSection.allCases
            case .myInfoVerify:
                // Does not need City since anything in Singapore is in...Singapore.
                return [
                    .street,
                    .unit,
                    .postcode,
                    .country
                ]
            }
        }
    }
    
    var mode: Mode = .nricEdit {
        didSet {
            self.configureForMode()
        }
    }
    
    weak var myInfoDelegate: MyInfoAddressUpdateDelegate?
    
    private lazy var dataSource = AddressEditDataSource(tableView: self.tableView,
                                                        sections: self.mode.sections,
                                                        delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureForMode()
    }
    
    @IBAction private func saveBarButtonTapped() {
        self.saveInput()
    }
    
    @IBAction private func cancelBarButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction private func continueTapped() {
        self.saveInput()
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    private func configureForMode() {
        guard self.footerView != nil else {
            // View has not loaded yet, this will be re-called in viewDidLoad.
            return
        }
        
        switch self.mode {
        case .nricEdit:
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.tableView.tableFooterView = self.footerView
            self.dataSource.reloadData()
        case .myInfoVerify(let myInfo):
            self.navigationItem.leftBarButtonItem = self.cancelBarButton
            self.navigationItem.rightBarButtonItem = self.saveBarButtton
            self.footerView.removeFromSuperview()
            guard let info = myInfo else {
                return
            }
            
            self.dataSource.setValue(info.street, forSection: .street)
            self.dataSource.setValue(info.unit, forSection: .unit)
            self.dataSource.setValue(info.postal, forSection: .postcode)
            self.dataSource.setValue(info.country, forSection: .country)
        }
    }
    
    private func saveInput() {
        switch self.mode {
        case .nricEdit:
            self.sendAddressToServer()
        case .myInfoVerify:
            self.updateMyInfo()
        }
    }
    
    private func sendAddressToServer() {
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        let address = self.buildAddress()
        
        self.spinnerView = showSpinner(onView: self.view)

        APIManager.shared.primeAPI
            .addAddress(address, forRegion: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] in
                let pendingVC = PendingVerificationViewController.fromStoryboard()
                self?.present(pendingVC, animated: true)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
        
    private func buildAddress() -> EKYCAddress {
        guard
            let street = self.dataSource.value(for: .street),
            let unit = self.dataSource.value(for: .unit),
            let city = self.dataSource.value(for: .city),
            let postcode = self.dataSource.value(for: .postcode),
            let country = self.dataSource.value(for: .country) else {
                fatalError("Somehow validation passed but one of these was null")
        }
            
        return EKYCAddress(street: street,
                           unit: unit,
                           city: city,
                           postcode: postcode,
                           country: country)
    }
    
    private func updateMyInfo() {
        guard let delegate = self.myInfoDelegate else {
            ApplicationErrors.assertAndLog("You're probably going to want to use a delegate here")
            return
        }
        
        let updatedAddress = MyInfoAddress(country: self.dataSource.value(for: .country),
                                           unit: self.dataSource.value(for: .unit),
                                           street: self.dataSource.value(for: .street),
                                           block: nil,
                                           postal: self.dataSource.value(for: .postcode),
                                           floor: nil,
                                           building: nil)
        
        delegate.addressUpdated(to: updatedAddress)
    }
}

extension AddressEditViewController: AddressEditDataSourceDelegate {
    
    func validityChanged(to valid: Bool) {
        switch self.mode {
        case .nricEdit:
            self.primaryButton.isEnabled = valid
        case .myInfoVerify:
            self.saveBarButtton.isEnabled = valid
        }
    }
}

extension AddressEditViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .address
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
