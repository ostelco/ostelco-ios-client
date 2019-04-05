//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var spinnerView: UIView?
    override func viewDidLoad() {
        view.backgroundColor = ThemeManager.currentTheme().mainColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyCredentials()
    }

    func verifyCredentials() {
        sharedAuth.credentialsManager.credentials { error, credentials in
            if error == nil, let credentials = credentials {
                if let accessToken = credentials.accessToken {
                    DispatchQueue.main.async {
                        let apiManager = APIManager.sharedInstance
                        let userManager = UserManager.sharedInstance
                        if (userManager.authToken != accessToken && userManager.authToken != nil) {
                            apiManager.wipeResources()
                            UserManager.sharedInstance.clear()
                        }

                        if (userManager.authToken != accessToken) {
                            apiManager.authHeader = "Bearer \(accessToken)"
                            UserManager.sharedInstance.authToken = accessToken
                        }

                        // TODO: New API does not handle refreshToken yet
                        /*
                        if let refreshToken = credentials.refreshToken {
                            ostelcoAPI.refreshToken = refreshToken
                        }
                        */

                        self.spinnerView = self.showSpinner(onView: self.view)
                        apiManager.context.load()
                            .onSuccess({ data in
                                if let context: Context = data.typedContent(ifNone: nil) {
                                    DispatchQueue.main.async {
                                        UserManager.sharedInstance.user = context.customer
                                    }

                                    var segueIdentifier: String

                                    if let region = context.getRegion() {
                                        DispatchQueue.main.async {
                                            OnBoardingManager.sharedInstance.region = region
                                        }
                                        switch region.status {
                                        case .PENDING:
                                            if let jumio = region.kycStatusMap.JUMIO, let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, let nricFin = region.kycStatusMap.NRIC_FIN {
                                                switch (jumio, addressAndPhoneNumber, nricFin) {
                                                case (.APPROVED, .APPROVED, .APPROVED):
                                                    segueIdentifier = "showEKYCLastScreen"
                                                case (.REJECTED, _, _):
                                                    segueIdentifier = "showEKYCOhNo"
                                                case (.PENDING, .APPROVED, .APPROVED):
                                                    segueIdentifier = "showEKYCLastScreen"
                                                default:
                                                    segueIdentifier = "showCountry"
                                                }
                                            } else {
                                                segueIdentifier = "showCountry"
                                            }
                                        case .APPROVED:
                                            // TODO: Redirect based on sim profiles in region
                                            segueIdentifier = "showESim"
                                        case .REJECTED:
                                            segueIdentifier = "showEKYCOhNo"
                                        }
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: segueIdentifier, sender: self)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "showCountry", sender: self)
                                        }
                                    }
                                } else {
                                    preconditionFailure("Failed to parse user context from server response.")
                                }
                            })
                            .onFailure({ error in
                                if let statusCode = error.httpStatusCode {
                                    switch statusCode {
                                    case 404:
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "showSignUp", sender: self)
                                        }
                                    default:
                                        preconditionFailure("Failed to fetch user context from server: \(error.userMessage)")
                                    }
                                } else {
                                    preconditionFailure("Failed to fetch user context from server: \(error.userMessage)")
                                }
                            })
                            .onCompletion({ _ in
                                self.removeSpinner(self.spinnerView)
                            })
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showLogin", sender: self)
            }
        }
        
    }
}
