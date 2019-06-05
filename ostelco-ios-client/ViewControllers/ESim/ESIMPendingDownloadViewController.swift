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

class ESIMPendingDownloadViewController: UIViewController {
    
    weak var coordinator: ESimCoordinator?
    var spinnerView: UIView?
    var simProfile: SimProfile? {
        didSet {
            let region = OnBoardingManager.sharedInstance.region!
            
            if let profile = self.simProfile {
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(region.region.name)SimProfileStatus", withValue: profile.status.rawValue)
            } else {
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(region.region.name)SimProfileStatus", withValue: "")
            }
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let region = OnBoardingManager.sharedInstance.region {
            self.getSimProfileForRegion(region: region)
        } else {
            self.loadRegion()
        }
    }
    
    @IBAction private func sendAgainTapped(_ sender: Any) {        
        if let simProfile = self.simProfile, let region = OnBoardingManager.sharedInstance.region {
        
            self.spinnerView = self.showSpinner(onView: self.view)
            
            APIManager.shared.primeAPI.resendEmailForSimProfileInRegion(code: region.region.id, iccId: simProfile.iccId)
                .ensure { [weak self] in
                    self?.removeSpinner(self?.spinnerView)
                    self?.spinnerView = nil
                }
                .done { [weak self] _ in
                    self?.showAlert(title: "Message", msg: "We have resent the QR code to your email address.")
                }
                .catch { [weak self] error in
                    ApplicationErrors.log(error)
                    debugPrint("Error resending email: \(error)")
                    self?.performSegue(withIdentifier: "showGenericOhNo", sender: self)
                }
        } else {
            ApplicationErrors.assertAndLog("Error sending email, simProfile or region is null?!")
            self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
        }
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        let region = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id
        
        self.spinnerView = self.showSpinner(onView: self.view)
        
        APIManager.shared.primeAPI
            .loadSimProfilesForRegion(code: countryCode)
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
                OnBoardingManager.sharedInstance.region = regionResponse
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
        let destination = self.coordinator!.determineDestination(from: profile)
        switch destination {
        case .pendingDownload:
            self.showAlert(title: "Message", msg: "Esim has not been downloaded yet. Current status: \(profile.status.rawValue)")
        default:
            self.coordinator?.navigate(to: destination, animated: true)
        }
    }
    
    func getSimProfileForRegion(region: RegionResponse) {
        guard
            let existingProfiles = region.simProfiles,
            existingProfiles.isNotEmpty else {
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
