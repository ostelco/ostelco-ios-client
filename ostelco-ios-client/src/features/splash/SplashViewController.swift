//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Auth0
import Siesta
import Promises

fileprivate func createError(_ message: String) -> NSError {
    return NSError(domain: Bundle.main.bundleIdentifier!,
                   code: 0,
                   userInfo: [NSLocalizedDescriptionKey: message])
}

class SplashViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var spinnerView: UIView?
    override func viewDidLoad() {
        view.backgroundColor = ThemeManager.currentTheme().mainColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyCredentialsP()
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

    // Fetches the credentials, in case of error, value will be nil
    func getCredentials() -> Promise<Credentials?> {
        let promise = Promise<Credentials?>.pending()
        // Check if we have credentials
        guard sharedAuth.credentialsManager.hasValid() else {
            promise.fulfill(nil)
            return promise
        }
        sharedAuth.credentialsManager.credentials { [self] error, credentials in
            if error == nil, let credentials = credentials {
                promise.fulfill(credentials)
            } else {
                print("Error fetching credentials from credentialsManager :", error ?? "No Error" )
                // In case of error allow to show login.
                promise.fulfill(nil)
            }
        }
        return promise
    }


    // Fetches the context, in case of error the promise is rejected
    func getContext() -> Promise<Context?> {
        let promise = Promise<Context?>.pending()
        func rejectPromise(_ error: RequestError) {
            let failure = "Failed to fetch user context from server: \(error.userMessage)"
            promise.reject(createError(failure))
        }
        spinnerView = showSpinner(onView: view)
        APIManager.sharedInstance.context.load().onSuccess { [self]  data in
            if let context: Context = data.typedContent(ifNone: nil) {
                promise.fulfill(context)
            } else {
                let failure = "Failed to parse user context from server response."
                promise.reject(createError(failure))
            }
        }.onFailure { error in
            if let statusCode = error.httpStatusCode, statusCode == 404 {
                // not found, assume user dosen't exist
                promise.fulfill(nil)
            } else {
                rejectPromise(error)
            }
        }.onCompletion { _ in
            self.removeSpinner(self.spinnerView)
        }
        return promise
    }

    func verifyCredentialsP() {

        let optCredentials = try! await(getCredentials())
        guard let credentials = optCredentials, let accessToken = credentials.accessToken else {
            performSegue(withIdentifier: "showLogin", sender: self)
            return
        }
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
        let optContext = try! await(getContext())
        guard let context = optContext else {
            // for 404 the context will be empty
            performSegue(withIdentifier: "showSignUp", sender: self)
            return
        }
        UserManager.sharedInstance.user = context.customer

        var segueIdentifier: String
        guard let region = context.getRegion() else {
            performSegue(withIdentifier: "showCountry", sender: self)
            return
        }
        OnBoardingManager.sharedInstance.region = region
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
        self.performSegue(withIdentifier: segueIdentifier, sender: self)
    }
}
