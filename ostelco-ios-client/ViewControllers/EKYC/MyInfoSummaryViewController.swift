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
    
    func updateProfile(_ controller: MyInfoSummaryViewController, profile: EKYCProfileUpdate)
    
    func fetchMyInfoDetails(_ controller: MyInfoSummaryViewController, code: String, completion: @escaping (MyInfoDetails) -> Void)
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
        updateUI(nil)
        loadMyInfo()
    }
    
    private func loadMyInfo() {
        guard let code = myInfoCode else {
            return
        }
        
        delegate?.fetchMyInfoDetails(self, code: code) { info in
            self.myInfoDetails = info
            self.updateUI(info)
        }
    }
    
    @IBAction private func editTapped() {
        delegate?.editSingPassAddress(myInfoDetails?.address, delegate: self)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard
            let details = myInfoDetails,
            let profileUpdate = EKYCProfileUpdate(myInfoDetails: details) else {
                ApplicationErrors.assertAndLog("Validation passed but we can't create a profile update?")
                fatalError("Validation passed but we can't create a profile update?")
        }
        
        delegate?.updateProfile(self, profile: profileUpdate)
    }
    
    func updateUI(_ myInfoDetails: MyInfoDetails?) {
        guard let myInfoDetails = myInfoDetails else {
            name.text = nil
            dob.text = nil
            address.text = nil
            nationality.text = nil
            residentialStatus.text = nil
            mobileNumber.text = nil
            sex.text = nil
            continueButton.isEnabled = false
            editButton.isEnabled = false
            return
        }
        name.text = myInfoDetails.name
        dob.text = myInfoDetails.dob
        address.text = myInfoDetails.address.formattedAddress
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
        
        editButton.isEnabled = true
        continueButton.isEnabled = address.text.hasTextOtherThanWhitespace
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
        navigationController?.popToViewController(self, animated: true)
        myInfoDetails?.address = address
        updateUI(myInfoDetails)
    }
}
