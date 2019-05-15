//
//  MyInfoSummaryViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

class MyInfoSummaryViewController: UIViewController {
    public var myInfoQueryItems: [URLQueryItem]?
    var spinnerView: UIView?
    var myInfoDetails: MyInfoDetails?
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var sex: UILabel!
    @IBOutlet private weak var dob: UILabel!
    @IBOutlet private weak var nationality: UILabel!
    @IBOutlet private weak var residentialStatus: UILabel!
    @IBOutlet private weak var address: UILabel!
    @IBOutlet private weak var mobileNumber: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI(nil)
        self.loadMyInfo()
    }
    
    private func loadMyInfo() {
        debugPrint("Query Items: \(String(describing: self.myInfoQueryItems))")
        guard let code = getMyInfoCode() else {
            return
        }
        
        debugPrint("Code = \(code)")
        
        self.reloadButton.isHidden = true
        self.spinnerView = self.showSpinner(onView: self.view)
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
                self?.showGenericError(error: error)
                self?.reloadButton.isHidden = false
            }
    }
    
    private func getMyInfoCode() -> String? {
        if let queryItems = myInfoQueryItems {
            if let codeItem = queryItems.first(where: { $0.name == "code" }) {
                return codeItem.value
            }
        }
        return nil
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "editAddress":
            guard
                let nav = segue.destination as? UINavigationController,
                let addressVC = nav.topViewController as? AddressEditViewController else {
                    ApplicationErrors.assertAndLog("Could not access correct view controller!")
                    return
            }
            
            addressVC.mode = .myInfoVerify(myInfo: self.myInfoDetails?.address)
            addressVC.myInfoDelegate = self
        default:
            break
        }
    }
    
    @IBAction private func tryAgainTapped() {
        self.loadMyInfo()
    }
    
    @IBAction private func editTapped() {
        self.performSegue(withIdentifier: "editAddress", sender: self)
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
                self?.performSegue(withIdentifier: "ESim", sender: self)
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
        self.continueButton.isEnabled = true
    }
}

extension MyInfoSummaryViewController: MyInfoAddressUpdateDelegate {
    
    func addressUpdated(to address: MyInfoAddress) {
        self.myInfoDetails?.address = address
        self.updateUI(self.myInfoDetails)
    }
}
