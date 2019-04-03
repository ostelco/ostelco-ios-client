//
//  ESIMPendingDownloadViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ESIMPendingDownloadViewController: UIViewController {
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "showHome", sender: self)
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
        
        /*
        showSpinner(onView: self.view)
        APIManager.sharedInstance.regions.child(countryCode)
            .load()
            .onSuccess { response in
                
            }
            .onFailure { requestError in
                
            }
            .onCompletion { _ in
                self.removeSpinner()
            }
         */
    }
}
