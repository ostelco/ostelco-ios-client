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

protocol AddressEditDelegate: class {
    func entered(address: EKYCAddress, regionCode: String)
    func cancel()
}

class AddressEditViewController: UITableViewController {
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var saveBarButtton: UIBarButtonItem!
    @IBOutlet private var cancelBarButton: UIBarButtonItem!
    
    weak var delegate: AddressEditDelegate?
    var regionCode: String!
    
    var spinnerView: UIView?
    
    enum Mode {
        case nricEnter
        case myInfoVerify(myInfo: MyInfoAddress?)
        
        var sections: [AddressEditSection] {
            switch self {
            case .nricEnter:
                return AddressEditSection.allCases
            case .myInfoVerify:
                // Does not need City since anything in Singapore is in...Singapore.
                return [
                    .unit,
                    .floor,
                    .block,
                    .building,
                    .street,
                    .postcode
                ]
            }
        }
    }
    
    var mode: Mode = .nricEnter
    
    weak var myInfoDelegate: MyInfoAddressUpdateDelegate!
    
    private lazy var dataSource = AddressEditDataSource(
        tableView: tableView,
        sections: mode.sections,
        delegate: self
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureForMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch mode {
        case .myInfoVerify:
            navigationController?.setNavigationBarHidden(false, animated: animated)
        case .nricEnter:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch mode {
        case .myInfoVerify:
            navigationController?.setNavigationBarHidden(true, animated: animated)
        case .nricEnter:
            break
        }
    }
    
    @IBAction private func saveBarButtonTapped() {
        saveInput()
    }
    
    @IBAction private func cancelBarButtonTapped() {
        delegate?.cancel()
    }
    
    @IBAction private func continueTapped() {
        saveInput()
    }
    
    @IBAction private func needHelpTapped() {
        showNeedHelpActionSheet()
    }
    
    private func configureForMode() {
        guard footerView != nil else {
            // View has not loaded yet, this will be re-called in viewDidLoad.
            return
        }
        
        switch mode {
        case .nricEnter:
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
            tableView.tableFooterView = footerView
            dataSource.reloadData()
        case .myInfoVerify(let myInfo):
            navigationItem.leftBarButtonItem = cancelBarButton
            navigationItem.rightBarButtonItem = saveBarButtton
            footerView.removeFromSuperview()
            guard let info = myInfo else {
                return
            }
            
            dataSource.setValue(info.floor, forSection: .floor)
            dataSource.setValue(info.unit, forSection: .unit)
            dataSource.setValue(info.block, forSection: .block)
            dataSource.setValue(info.building, forSection: .building)
            dataSource.setValue(info.street, forSection: .street)
            dataSource.setValue(info.postal, forSection: .postcode)
        }
    }
    
    private func saveInput() {
        switch mode {
        case .nricEnter:
            sendAddressToServer()
        case .myInfoVerify:
            updateMyInfo()
        }
    }
    
    private func sendAddressToServer() {
        if case .myInfoVerify = mode {
            ApplicationErrors.assertAndLog("You shouldn't be able to send the address to the server from myInfo verify mode")
        }
        
        let address = buildAddress()
        
        spinnerView = showSpinner()

        delegate?.entered(address: address, regionCode: regionCode)
    }
        
    private func buildAddress() -> EKYCAddress {
        guard
            let floor = dataSource.value(for: .floor),
            let unit = dataSource.value(for: .unit),
            let block = dataSource.value(for: .block),
            let building = dataSource.value(for: .building),
            let street = dataSource.value(for: .street),
            let postcode = dataSource.value(for: .postcode) else {
                fatalError("Somehow validation passed but one of these was null")
        }
            
        return EKYCAddress(
            floor: floor,
            unit: unit,
            block: block,
            building: building,
            street: street,
            postcode: postcode
        )
    }
    
    private func updateMyInfo() {
        let updatedAddress = MyInfoAddress(
            floor: dataSource.value(for: .floor),
            unit: dataSource.value(for: .unit),
            block: dataSource.value(for: .block),
            building: dataSource.value(for: .building),
            street: dataSource.value(for: .street),
            postal: dataSource.value(for: .postcode)
        )
        
        myInfoDelegate.addressUpdated(to: updatedAddress)
    }
}

extension AddressEditViewController: AddressEditDataSourceDelegate {
    
    func validityChanged(to valid: Bool) {
        switch mode {
        case .nricEnter:
            primaryButton.isEnabled = valid
        case .myInfoVerify:
            saveBarButtton.isEnabled = valid
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
