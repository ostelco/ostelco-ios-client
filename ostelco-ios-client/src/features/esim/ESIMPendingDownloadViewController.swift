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
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func sendAgainTapped(_ sender: Any) {
        showAlert(title: "Error", msg: "We can't do that yet, sorry for the inconvenience. (It's actually not implemented)")
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        let region = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id
        
        showSpinner(onView: self.view)
        APIManager.sharedInstance.regions.child(countryCode).child("simProfiles").load()
            .onSuccess { data in
                if let simProfile: SimProfile = data.typedContent(ifNone: nil) {
                    // TODO: Check sim proflie status and act accordingly
                    /*
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showHome", sender: self)
                    }
                    */
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
                self.removeSpinner()
            }
    }
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    override func viewDidLoad() {
        let region  = OnBoardingManager.sharedInstance.region!
        let countryCode = region.region.id
        
        if let simProfiles = region.simProfiles, simProfiles.count > 0 {
            let simProfile = simProfiles[0]
        } else {
            showSpinner(onView: self.view)
            APIManager.sharedInstance.regions.child(countryCode).child("simProfiles").request(.post)
                .onSuccess { data in
                    if let simProfile: SimProfile = data.typedContent(ifNone: nil) {
                        // TODO: Check sim proflie status and act accordingly
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
                    self.removeSpinner()
                }
        }
    }
}
