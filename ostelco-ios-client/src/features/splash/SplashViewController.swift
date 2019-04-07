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
import PromiseKit

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
        verifyCredentials()
    }

    // Fetches the credentials, in case of error, value will be nil
    func getCredentials() -> Promise<Credentials?> {
        let empty: Credentials? = nil
        // Check if we have credentials
        return Promise<Credentials?> { seal in
            guard sharedAuth.credentialsManager.hasValid() else {
                seal.resolve(empty, nil)
                return
            }
            sharedAuth.credentialsManager.credentials { error, credentials in
                if error == nil, let credentials = credentials {
                    seal.resolve(credentials, nil)
                } else {
                    print("Error fetching credentials from credentialsManager :", error ?? "No Error" )
                    // In case of error allow to show login.
                    seal.resolve(empty, nil)
                }
            }
        }
    }


    // Fetches the context, in case of error the promise is rejected
    func getContext() -> Promise<Context?> {
        let empty: Context? = nil
        return Promise<Context?> { seal in
            func rejectPromise(_ error: RequestError) {
                let failure = "Failed to fetch user context from server: \(error.userMessage)"
                seal.reject(createError(failure))
            }
            spinnerView = showSpinner(onView: view)
            APIManager.sharedInstance.context.load().onSuccess { data in
                if let context: Context = data.typedContent(ifNone: nil) {
                    seal.resolve(context, nil)
                } else {
                    let failure = "Failed to parse user context from server response."
                    seal.reject(createError(failure))
                }
            }.onFailure { error in
                if let statusCode = error.httpStatusCode, statusCode == 404 {
                    // not found, assume user dosen't exist
                    seal.resolve(empty, nil)
                } else {
                    rejectPromise(error)
                }
            }.onCompletion { _ in
                self.removeSpinner(self.spinnerView)
            }
        }
    }

    func setCredentials(_ credentials: Credentials?) -> Bool {
        if let credentials = credentials, let accessToken = credentials.accessToken {
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
            return true
        }
        return false
    }

    func getContextFromCredentials(_ credentials: Credentials?) -> Promise<Context?> {
        if setCredentials(credentials) {
            print("setCredentials, calling getContext")
            return self.getContext()
        } else {
            performSegue(withIdentifier: "showLogin", sender: self)
            // Stop further processing of the promise chain
            let rejected: Promise<Context?> = getRejectedPromise()
            return rejected
        }
    }

    func handleContext(_ context: Context?) -> Promise<Void?> {
        if let context = context {
            print("handleContext")
            UserManager.sharedInstance.user = context.customer
            if let region = context.getRegion() {
                OnBoardingManager.sharedInstance.region = region
                let segueIdentifier = getSegueFromRegionResponse(region: region)
                print("handleContext switch to segue \(segueIdentifier)")
                performSegue(withIdentifier: segueIdentifier, sender: self)
            } else {
                print("handleContext switch to showCountry")
                performSegue(withIdentifier: "showCountry", sender: self)
            }
        } else {
            // for 404 the context will be empty
            print("handleContext empty context 404")
            performSegue(withIdentifier: "showSignUp", sender: self)
        }
        let resolved: Promise<Void?> = getFullfilledPromise()
        return resolved
    }

    func getRejectedPromise<T>() -> Promise<T?> {
        return Promise<T?> { seal in
            let message = "Terminating promise chain, ignore"
            seal.reject(createError(message))
        }
    }

    func getFullfilledPromise<T>() -> Promise<T?> {
        let empty:T? = nil
        return Promise<T?> { seal in
            seal.resolve(empty, nil)
        }
    }

    func getRejectedContext() -> Promise<Context?> {
        let empty: Context? = nil
        return Promise<Context?> { seal in
            func rejectPromise(_ error: RequestError) {
                let failure = "Failed to fetch user context from server: \(error.userMessage)"
                seal.reject(createError(failure))
            }
            spinnerView = showSpinner(onView: view)
            APIManager.sharedInstance.context.load().onSuccess { data in
                if let context: Context = data.typedContent(ifNone: nil) {
                    seal.resolve(context, nil)
                } else {
                    let failure = "Failed to parse user context from server response."
                    seal.reject(createError(failure))
                }
                }.onFailure { error in
                    if let statusCode = error.httpStatusCode, statusCode == 404 {
                        // not found, assume user dosen't exist
                        seal.resolve(empty, nil)
                    } else {
                        rejectPromise(error)
                    }
                }.onCompletion { _ in
                    self.removeSpinner(self.spinnerView)
            }
        }
    }

    func getSegueFromRegionResponse(region: RegionResponse) -> String {
        var segueIdentifier: String
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
        return segueIdentifier
    }

    func verifyCredentials() -> Promise<Void> {
        return getCredentials().then { credentials in
            return self.getContextFromCredentials(credentials)
        }.done { context in
            self.handleContext(context)
        }
    }
}
