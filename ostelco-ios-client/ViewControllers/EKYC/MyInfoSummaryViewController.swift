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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("Query Items: \(String(describing: self.myInfoQueryItems))")
        guard let code = getMyInfoCode() else {
            return
        }
        
        debugPrint("Code = \(code)")
        
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
                    assertionFailure("Could not access correct view controller!")
                    return
            }
            
            addressVC.mode = .myInfoVerify(myInfo: self.myInfoDetails?.address)
            addressVC.myInfoDelegate = self
        default:
            break
        }
    }
    
    @IBAction private func `continue`(_ sender: Any) {
        guard
            let address = self.address.text,
            let phoneNumber = self.myInfoDetails?.mobileNumber?.formattedNumber else {
                assertionFailure("Validation passed but we don't have either an address or a phone number?")
                return
        }
        
        let profileUpdate = EKYCProfileUpdate(address: address, phoneNumber: phoneNumber)
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
            return
        }
        name.text = myInfoDetails.name
        dob.text = myInfoDetails.dob
        address.text = "\(myInfoDetails.address.getAddressLine1())\n\(myInfoDetails.address.getAddressLine2())"
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
    }
}

extension MyInfoSummaryViewController: MyInfoAddressUpdateDelegate {
    
    func addressUpdated(to address: MyInfoAddress) {
        self.myInfoDetails?.address = address
        self.updateUI(self.myInfoDetails)
    }
}
