//
//  PendingVerificationViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

protocol PendingVerificationDelegate: class {
    func waitingCompletedSuccessfully(for region: PrimeGQL.RegionDetailsFragment)
    func countryCode() -> String
    func waitingCompletedWithRejection()
}

class PendingVerificationViewController: UIViewController {
    
    // for PushNotificationHandling
    var pushNotificationObserver: NSObjectProtocol?
    
    // for DidBecomeActiveHandling
    var didBecomeActiveObserver: NSObjectProtocol?
    
    @IBOutlet private var gifView: LoopingVideoView!

    weak var delegate: PendingVerificationDelegate?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gifView.videoURL = GifVideo.time.url
        self.gifView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.addPushNotificationListener()
        self.addDidBecomeActiveObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removePushNotificationListener()
        self.removeDidBecomeActiveObserver()
    }
    
    // MARK: - IBActions
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func `continue`(_ sender: Any) {
        self.checkVerificationStatus()
    }
    
    func checkVerificationStatus(silentCheck: Bool = false) {
        guard let countryCode = delegate?.countryCode() else {
            fatalError("Missing country code!")
        }
        
        let spinnerView = showSpinner()
        APIManager.shared.primeAPI
            .loadRegion(code: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(spinnerView)
            }
            .done { [weak self] regionResponse in
                switch regionResponse.status {
                case .approved:
                    self?.delegate?.waitingCompletedSuccessfully(for: regionResponse)
                default:
                    self?.handleRegionPendingOrRejected(silentCheck: silentCheck, regionResponse: regionResponse)
                }
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    func handleRegionPending(silentCheck: Bool = false) {
        if !silentCheck {
            showAlert(title: "Status", msg: "Please hold on! We are still checking your docs.")
        }
    }
    
    func handleRegionPendingOrRejected(silentCheck: Bool = false, regionResponse: PrimeGQL.RegionDetailsFragment) {
        if
            let jumioStatus = regionResponse.kycStatusMap.jumio,
            let nricStatus = regionResponse.kycStatusMap.nricFin,
            let addressStatus = regionResponse.kycStatusMap.addressAndPhoneNumber {
            switch (jumioStatus, nricStatus, addressStatus) {
            case (.rejected, _, _), (_, .rejected, _), (_, _, .rejected):
                self.delegate?.waitingCompletedWithRejection()
            case (.approved, .approved, .approved):
                self.delegate?.waitingCompletedSuccessfully(for: regionResponse)
            case (.pending, _, _), (_, .pending, _), (_, _, .pending):
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
    
    func showGenericOhNo() {
        let ohNo = OhNoViewController.fromStoryboard(type: .generic(code: nil))
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak self] in
                self?.checkVerificationStatus()
            })
        }
        self.present(ohNo, animated: true)
    }
}

// MARK: - StoryboardLoadable

extension PendingVerificationViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

// MARK: - PushNotificationHandling

extension PendingVerificationViewController: PushNotificationHandling {
    
    func handlePushNotification(_ notification: PushNotificationContainer) {
        guard let scanInfo = notification.scanInfo else {
            // This is some other kind of notification
            return
        }
        
        switch scanInfo.status {
        case .APPROVED:
            self.checkVerificationStatus()
        case .REJECTED:
            self.delegate?.waitingCompletedWithRejection()
        case .PENDING:
            self.handleRegionPending(silentCheck: true)
        }
    }
}

// MARK: - DidBecomeActiveHandling

extension PendingVerificationViewController: DidBecomeActiveHandling {
    
    func handleDidBecomeActive() {
        self.checkVerificationStatus(silentCheck: true)
    }
}
