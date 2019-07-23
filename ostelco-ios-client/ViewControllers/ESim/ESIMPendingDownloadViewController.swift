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
    func profileChanged(_ profile: PrimeGQL.SimProfileFields)
    func countryCode() -> String
}

class ESIMPendingDownloadViewController: UIViewController {
    
    weak var delegate: ESIMPendingDownloadDelegate?
    var spinnerView: UIView?
    var simProfile: PrimeGQL.SimProfileFields?
    
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
    
    private func handleGotSimProfiles(_ profiles: [PrimeGQL.SimProfileFields]) {
        guard let profile = profiles.first(where: {
            $0.iccId == self.simProfile?.iccId
        }) else {
            self.showAlert(title: "Error", msg: "Could not find which esim profile ")
            return
        }
        
        self.simProfile = profile
        if profile.status == .installed {
            self.delegate!.profileChanged(profile)
        }
    }
    
    func getSimProfileForRegion(region: PrimeGQL.RegionDetailsFragment) {
        guard let existingProfiles = region.simProfiles, existingProfiles.isNotEmpty else {
            self.createSimProfileForRegion(region)
            return
        }
        
        if let enabledProfile = existingProfiles.first(where: { $0.fragments.simProfileFields.status == .enabled }) {
            self.simProfile = enabledProfile.fragments.simProfileFields
        } else if let almostReadyProfile = existingProfiles.first(where: { [.availableForDownload, .downloaded, .installed].contains($0.fragments.simProfileFields.status) }) {
            self.simProfile = almostReadyProfile.fragments.simProfileFields
        } else {
            self.simProfile = existingProfiles.first?.fragments.simProfileFields
        }
        
        self.handleGotSimProfiles(existingProfiles.map({ $0.fragments.simProfileFields }))
    }
    
    private func createSimProfileForRegion(_ region: PrimeGQL.RegionDetailsFragment) {
        let countryCode = region.region.id
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.shared.primeAPI
            .createSimProfileForRegion(code: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] profile in
                self?.simProfile = profile.getGraphQLModel().fragments.simProfileFields
                self?.handleGotSimProfiles([profile.getGraphQLModel().fragments.simProfileFields])
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
