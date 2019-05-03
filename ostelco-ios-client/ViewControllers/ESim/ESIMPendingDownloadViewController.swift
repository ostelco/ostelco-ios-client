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
            getSimProfileForRegion(region: region)
        } else {
           APIManager.sharedInstance
            .loggedInAPI
            .getRegionFromRegions()
            .done { [weak self] regionResponse in
                OnBoardingManager.sharedInstance.region = regionResponse
                self?.getSimProfileForRegion(region: regionResponse)
            }
            .catch { [weak self] error in
                debugPrint("Error getting region: \(error)")
                self?.performSegue(withIdentifier: "showGenericOhNo", sender: self)
            }
        }
    }
    
    @IBAction private func sendAgainTapped(_ sender: Any) {
        showAlert(title: "Error", msg: "We can't do that yet, sorry for the inconvenience. (It's actually not implemented)")
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        let region = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id
        
        self.spinnerView = self.showSpinner(onView: self.view)
        
        APIManager.sharedInstance.loggedInAPI
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
    
    private func handleGotSimProfiles(_ profiles: [SimProfile]) {
        guard let profile = profiles.first(where: {
            $0.iccId == self.simProfile?.iccId
        }) else {
            self.showAlert(title: "Error", msg: "Could not find which esim profile ")
            return
        }
        
        self.simProfile = profile
        switch profile.status {
        case .AVAILABLE_FOR_DOWNLOAD:
            self.showAlert(title: "Message", msg: "Esim has not been downloaded yet. Current status: \(profile.status.rawValue)")
        case .NOT_READY:
            self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
        default:
            self.performSegue(withIdentifier: "showHome", sender: self)
        }
    }
    
    func getSimProfileForRegion(region: RegionResponse) {
        let countryCode = region.region.id
        if let simProfiles = region.simProfiles, simProfiles.isNotEmpty {
            if simProfiles.contains(where: { $0.status == .ENABLED }) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showHome", sender: self)
                }
            } else {
                simProfile = simProfiles.first(where: { [.AVAILABLE_FOR_DOWNLOAD, .DOWNLOADED, .INSTALLED].contains($0.status) })
            }
        } else {
            spinnerView = showSpinner(onView: self.view)
            APIManager.sharedInstance.regions.child(countryCode).child("simProfiles").withParam("profileType", "iphone").request(.post)
                .onSuccess { data in
                    if let simProfile: SimProfile = data.typedContent(ifNone: nil) {
                        self.simProfile = simProfile
                    } else {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
                        }
                    }
                }
                .onFailure { requestError in
                    if let statusCode = requestError.httpStatusCode {
                        switch statusCode {
                        default:
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
                        }
                    }
                }
                .onCompletion { _ in
                    self.removeSpinner(self.spinnerView)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotificationObserver(selector: #selector(onDidReceiveData(_:)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObserver()
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        print(#function, "Notification didReceivePushNotification arrived")
    }
}
