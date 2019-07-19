//
//  ESIMPendingDownloadViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Crashlytics
import ostelco_core

protocol ESIMPendingDownloadDelegate: class {
    func profileChanged(_ profile: SimProfile)
    func countryCode() -> String
}

class ESIMPendingDownloadViewController: UIViewController {
    
    weak var delegate: ESIMPendingDownloadDelegate?
    var spinnerView: UIView?
    var simProfile: SimProfile?
    
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRegion()
    }
    
    @IBAction private func sendAgainTapped(_ sender: Any) {
        let simProfile = self.simProfile!
        let countryCode = delegate?.countryCode()
        
        self.spinnerView = self.showSpinner(onView: self.view)
        
        APIManager.shared.primeAPI
            .resendEmailForSimProfileInRegion(code: countryCode!, iccId: simProfile.iccId)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] _ in
                self?.showAlert(title: "Message", msg: "We have resent the QR code to your email address.")
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        let countryCode = delegate?.countryCode()
        
        self.spinnerView = self.showSpinner(onView: self.view)
        
        APIManager.shared.primeAPI
            .loadSimProfilesForRegion(code: countryCode!)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] simProfiles in
                self?.handleGotSimProfiles(simProfiles)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        self.showNeedHelpActionSheet()
    }
    
    private func loadRegion() {
        APIManager.shared.primeAPI
            .getRegionFromRegions()
            .done { [weak self] regionResponse in
                self?.getSimProfileForRegion(region: regionResponse)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    private func handleGotSimProfiles(_ profiles: [SimProfile]) {
        guard let profile = profiles.first(where: {
            $0.iccId == self.simProfile?.iccId
        }) else {
            self.showAlert(title: "Error", msg: "Could not find which esim profile ")
            return
        }
        
        self.simProfile = profile
        if profile.status == .INSTALLED {
            self.delegate!.profileChanged(profile)
        }
    }
    
    func getSimProfileForRegion(region: RegionResponse) {
        guard let existingProfiles = region.simProfiles, existingProfiles.isNotEmpty else {
            self.createSimProfileForRegion(region)
            return
        }
        
        if let enabledProfile = existingProfiles.first(where: { $0.status == .ENABLED }) {
            self.simProfile = enabledProfile
        } else if let almostReadyProfile = existingProfiles.first(where: { [.AVAILABLE_FOR_DOWNLOAD, .DOWNLOADED, .INSTALLED].contains($0.status) }) {
            self.simProfile = almostReadyProfile
        } else {
            self.simProfile = existingProfiles.first
        }
        
        self.handleGotSimProfiles(existingProfiles)
    }
    
    private func createSimProfileForRegion(_ region: RegionResponse) {
        let countryCode = region.region.id
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.shared.primeAPI
            .createSimProfileForRegion(code: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] profile in
                self?.simProfile = profile
                self?.handleGotSimProfiles([profile])
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
}

extension ESIMPendingDownloadViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
