//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

class SplashViewController: UIViewController, StoryboardLoadable {
    static let storyboard: Storyboard = .splash
    static let isInitialViewController = true
    
    @IBOutlet private weak var imageView: UIImageView!
    var spinnerView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme().mainColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyCredentials()
    }
    
    func verifyCredentials() {
        guard let accessToken = APIManager.sharedInstance.secureStorage.getString(for: .Auth0Token) else {
            self.performSegue(withIdentifier: "showLogin", sender: self)
            return
        }
        
//        let apiManager = APIManager.sharedInstance
//        let userManager = UserManager.sharedInstance
//        if userManager.authToken != accessToken && userManager.authToken != nil {
//            apiManager.wipeResources()
//            UserManager.sharedInstance.clear()
//        }
//
//        if userManager.authToken != accessToken {
//            apiManager.authHeader = "Bearer \(accessToken)"
//            UserManager.sharedInstance.authToken = accessToken
//            sharedAuth.credentialsSecureStorage.setString(accessToken, for: .Auth0Token)
//        }
//
        // TODO: New API does not handle refreshToken yet
        /*
         if let refreshToken = credentials.refreshToken {
         ostelcoAPI.refreshToken = refreshToken
         }
         */
        // Send the FCM Token, if it is ready.
        UIApplication.shared.typedDelegate.sendFCMToken()
        
        self.loadContext()
    }
    
    private func loadContext() {
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.sharedInstance.loggedInAPI.loadContext()
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] context in
                UserManager.sharedInstance.user = context.customer
                guard let region = context.getRegion() else {
                    self?.showCountry()
                    return
                }
                self?.handleRegionResponse(region)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
    
    private func handleRegionResponse(_ region: RegionResponse) {
        OnBoardingManager.sharedInstance.region = region
        var segueIdentifier: String
        switch region.status {
        case .PENDING:
            if let jumio = region.kycStatusMap.JUMIO, let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, let nricFin = region.kycStatusMap.NRIC_FIN {
                switch (jumio, addressAndPhoneNumber, nricFin) {
                case (.APPROVED, .APPROVED, .APPROVED):
                    segueIdentifier = "showEKYCLastScreen"
                case (.REJECTED, _, _):
                    self.showOhNo()
                    return
                case (.PENDING, .APPROVED, .APPROVED):
                    segueIdentifier = "showEKYCLastScreen"
                default:
                    self.showCountry()
                    return
                }
            } else {
                self.showCountry()
                return
            }
        case .APPROVED:
            if let simProfile = region.getSimProfile() {
                switch simProfile.status {
                // TODO: NOT_READY should probably send user to one of our error screens
                case .AVAILABLE_FOR_DOWNLOAD, .NOT_READY:
                    segueIdentifier = "showESim"
                default:
                    segueIdentifier = "showHome"
                }
            } else {
                segueIdentifier = "showESim"
            }
        case .REJECTED:
            segueIdentifier = "showEKYCOhNo"
        }
        
        self.performSegue(withIdentifier: segueIdentifier, sender: self)

    }
    
    private func showCountry() {
        self.performSegue(withIdentifier: "showCountry", sender: self)
    }
    
    private func showOhNo() {
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
}
