//
//  MyInfoSummaryViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

protocol MyInfoSummaryDelegate: class {
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate)
    func verifiedSingPassAddress()
    func failedToLoadMyInfo()
}

class MyInfoSummaryViewController: UIViewController {
    var spinnerView: UIView?
    var myInfoDetails: MyInfoDetails?
    
    var myInfoCode: String?
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var sex: UILabel!
    @IBOutlet private weak var dob: UILabel!
    @IBOutlet private weak var nationality: UILabel!
    @IBOutlet private weak var residentialStatus: UILabel!
    @IBOutlet private weak var address: UILabel!
    @IBOutlet private weak var mobileNumber: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    
    weak var delegate: MyInfoSummaryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI(nil)
        self.loadMyInfo()
    }
    
    private func loadMyInfo() {
        guard let code = myInfoCode else {
            return
        }
        
        self.spinnerView = self.showSpinner(onView: self.view, loadingText: "Loading your data from SingPass...")
        APIManager.shared.primeAPI
            .loadSingpassInfo(code: code)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] myInfoDetails in
                self?.myInfoDetails = myInfoDetails
                self?.updateUI(myInfoDetails)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error) { _ in
                    self?.delegate?.failedToLoadMyInfo()
                }
            }
    }
    
    @IBAction private func editTapped() {
        self.delegate?.editSingPassAddress(self.myInfoDetails?.address, delegate: self)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard
            let details = self.myInfoDetails,
            let profileUpdate = EKYCProfileUpdate(myInfoDetails: details) else {
                ApplicationErrors.assertAndLog("Validation passed but we can't create a profile update?")
                return
        }
        
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.shared.primeAPI.updateEKYCProfile(with: profileUpdate, forRegion: "sg")
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] in
                self?.delegate?.verifiedSingPassAddress()
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    func updateUI(_ myInfoDetails: MyInfoDetails?) {
        guard let myInfoDetails = myInfoDetails else {
            self.name.text = nil
            self.dob.text = nil
            self.address.text = nil
            self.nationality.text = nil
            self.residentialStatus.text = nil
            self.mobileNumber.text = nil
            self.sex.text = nil
            self.continueButton.isEnabled = false
            self.editButton.isEnabled = false
            return
        }
        self.name.text = myInfoDetails.name
        self.dob.text = myInfoDetails.dob
        self.address.text = myInfoDetails.address.formattedAddress
        if let nationality = myInfoDetails.nationality {
            self.nationality.text = nationality
        }
        if let residentialStatus = myInfoDetails.residentialStatus {
            self.residentialStatus.text = residentialStatus
        }
        if let mobileNumber = myInfoDetails.mobileNumber?.formattedNumber {
            self.mobileNumber.text = mobileNumber
        }
        if let sex = myInfoDetails.sex {
            self.sex.text = sex
        }
        
        self.editButton.isEnabled = true
        self.continueButton.isEnabled = self.address.text.hasTextOtherThanWhitespace
    }
}

extension MyInfoSummaryViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

extension MyInfoSummaryViewController: MyInfoAddressUpdateDelegate {
    
    func addressUpdated(to address: MyInfoAddress) {
        self.navigationController?.popToViewController(self, animated: true)
        self.myInfoDetails?.address = address
        self.updateUI(self.myInfoDetails)
    }
}
