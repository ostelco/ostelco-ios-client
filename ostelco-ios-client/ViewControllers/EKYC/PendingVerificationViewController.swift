//
//  PendingVerificationViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class PendingVerificationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func `continue`(_ sender: Any) {
        checkVerificationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotificationObserver(selector: #selector(onDidReceiveData(_:)))
        addWillEnterForegroundObserver(selector: #selector(didBecomeActive))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObserver()
        removeWillEnterForegroundObserver()
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        print(#function, "Notification didReceivePushNotification arrived")
    }
    
    @objc func didBecomeActive() {
        checkVerificationStatus(silentCheck: true)
    }
    
    func checkVerificationStatus(silentCheck: Bool = false) {
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        let spinnerView = showSpinner(onView: self.view)
        APIManager.sharedInstance.regions.child(countryCode).load()
            .onSuccess { data in
                if let regionResponse: RegionResponse = data.typedContent(ifNone: nil) {
                    // if let regionRespons.kycStatusMap.NR
                    // TODO: Convert status to enum
                    switch regionResponse.status {
                    case .APPROVED:
                        self.performSegue(withIdentifier: "ESim", sender: self)
                    case .PENDING:
                        if !silentCheck {
                            self.showAlert(title: "Status", msg: regionResponse.status.rawValue)
                        }
                    case .REJECTED:
                        if let jumioStatus = regionResponse.kycStatusMap.JUMIO, let nricStatus = regionResponse.kycStatusMap.NRIC_FIN, let addressStatus = regionResponse.kycStatusMap.ADDRESS_AND_PHONE_NUMBER {
                            switch (jumioStatus, nricStatus, addressStatus) {
                            case (.REJECTED, _, _), (_, .REJECTED, _), (_, _, .REJECTED):
                                // If any of the statuses have been rejected, send user to ekyc oh no screen, they need to complete the whole ekyc again to continue
                                // TODO: segue to ekyc oh no screen
                                break
                            case (.APPROVED, .APPROVED, .APPROVED):
                                // Should not happend, because this case should've been handled further up the stack, but we will let them pass for now
                                self.performSegue(withIdentifier: "ESim", sender: self)
                            default:
                                // This case means any of the above is pending, thus user has to wait
                                if !silentCheck {
                                    self.showAlert(title: "Status", msg: regionResponse.status.rawValue)
                                }
                            }
                        } else {
                            // If none of the variables above are set in the kycStatusMap, something weird has happened, send user to generic contact support screen
                            // TODO: segue to generic oh no screen
                        }
                    }
                } else {
                    // TODO: Create more descriptive error. Not sure if this cause ever will happen, but that doesn't mean we shouldn't handle it somehow.
                    self.showAlert(title: "Error", msg: "Failed to parse region from server response.")
                }
            }
            .onFailure { error in
                self.showAPIError(error: error)
            }
            .onCompletion { _ in
                self.removeSpinner(spinnerView)
        }
    }
}
