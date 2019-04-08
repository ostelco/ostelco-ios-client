//
//  ESIMPendingDownloadViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Crashlytics

class ESIMPendingDownloadViewController: UIViewController {
    var spinnerView: UIView?
    var simProfile: SimProfile! {
        didSet {
            let region = OnBoardingManager.sharedInstance.region!
            if simProfile != nil {
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(region.region.name)SimProfileStatus", withValue: simProfile.status.rawValue)
            } else {
                Freshchat.sharedInstance()?.setUserPropertyforKey("\(region.region.name)SimProfileStatus", withValue: "")
            }
        }
    }

    @IBOutlet weak var continueButton: UIButton!

    @IBAction func sendAgainTapped(_ sender: Any) {
        showAlert(title: "Error", msg: "We can't do that yet, sorry for the inconvenience. (It's actually not implemented)")
    }

    @IBAction func continueTapped(_ sender: Any) {
        let region = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id

        spinnerView = showSpinner(onView: self.view)
        APIManager.sharedInstance.regions.child(countryCode).child("simProfiles").load()
            .onSuccess { data in
                if let simProfiles: [SimProfile] = data.typedContent(ifNone: nil) {
                    if let simProfile = simProfiles.first(where: {
                        $0.eSimActivationCode == self.simProfile.eSimActivationCode
                    }) {
                        self.simProfile = simProfile
                        switch simProfile.status {
                        case .AVAILABLE_FOR_DOWNLOAD, .INSTALLED, .DOWNLOADED:
                            self.showAlert(title: "Message", msg: "Esim has not been downloaded yet. Current status: \(simProfile.status.rawValue)")
                        default:
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "showHome", sender: self)
                            }
                        }
                    } else {
                        self.showAlert(title: "Error", msg: "Could not find which esim profile ")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showGenericOhNo", sender: self)
                    }
                }
            }
            .onFailure { requestError in
                Crashlytics.sharedInstance().recordError(requestError)
                self.showAPIError(error: requestError)
            }
            .onCompletion { _ in
                self.removeSpinner(self.spinnerView)
        }
    }

    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }

    override func viewDidLoad() {
        let region  = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id

        if let simProfiles = region.simProfiles, simProfiles.count > 0 {
            if simProfiles.first(where: { $0.status == .ENABLED }) != nil {
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
}
