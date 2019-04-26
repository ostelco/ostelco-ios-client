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
                    switch regionResponse.status {
                    case .APPROVED:
                        self.handleRegionApproved()
                    default:
                        self.handleRegionPendingOrRejected(silentCheck: silentCheck, regionResponse: regionResponse)
                    }
                } else {
                    // TODO: Need to figure out what error code we should pass to generic error screen here
                    self.showGenericOhNo()
                }
            }
            .onFailure { error in
                self.showAPIError(error: error)
            }
            .onCompletion { _ in
                self.removeSpinner(spinnerView)
        }
    }
    
    func handleRegionApproved() {
        performSegue(withIdentifier: "ESim", sender: nil)
    }
    
    func handleRegionPending(silentCheck: Bool = false) {
        if !silentCheck {
            showAlert(title: "Status", msg: "Please hold on! We are still checking your docs.")
        }
    }
    
    func handleRegionPendingOrRejected(silentCheck: Bool = false, regionResponse: RegionResponse) {
        if let jumioStatus = regionResponse.kycStatusMap.JUMIO, let nricStatus = regionResponse.kycStatusMap.NRIC_FIN, let addressStatus = regionResponse.kycStatusMap.ADDRESS_AND_PHONE_NUMBER {
            switch (jumioStatus, nricStatus, addressStatus) {
            // case (let jumioStatus, let nricStatus, let addressStatus) where jumioStatus == .REJECTED || nricStatus == .REJECTED || addressStatus == .REJECTED:
            case (.REJECTED, _, _), (_, .REJECTED, _), (_, _, .REJECTED):
                // If any of the statuses have been rejected, send user to ekyc oh no screen, they need to complete the whole ekyc again to continue
                self.showEKYCOhNo()
                break
            case (.APPROVED, .APPROVED, .APPROVED):
                // Should not happend, because this case should've been handled further up the stack, but we will let them pass for now
                self.performSegue(withIdentifier: "ESim", sender: self)
            // case (let jumioStatus, let nricStatus, let addressStatus) where jumioStatus == .PENDING || nricStatus == .PENDING || addressStatus == .PENDING:
            case (.PENDING, _, _), (_, .PENDING, _), (_, _, .PENDING):
                self.handleRegionPending(silentCheck: silentCheck)
            default:
                // This case means any of the above is pending, thus user has to wait
                if !silentCheck {
                    self.showAlert(title: "Status", msg: regionResponse.status.rawValue)
                }
            }
        } else {
            // If none of the variables above are set in the kycStatusMap, something weird has happened, send user to generic contact support screen
            // TODO: Need to figure out what error code we should pass to generic error screen here
            showGenericOhNo()
        }
    }
    
    func showEKYCOhNo() {
        let ohNo = OhNoViewController.fromStoryboard(type: .ekycRejected)
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                let selectVerificationMethodVC = SelectIdentityVerificationMethodViewController.fromStoryboard()
                self.present(selectVerificationMethodVC, animated: true)
            })
        }
        self.present(ohNo, animated: true)
    }
    
    func showGenericOhNo() {
        let ohNo = OhNoViewController.fromStoryboard(type: .generic(code: nil))
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else {
                    return
                }
              
                self.checkVerificationStatus()
            })
        }
        self.present(ohNo, animated: true)
    }
}
