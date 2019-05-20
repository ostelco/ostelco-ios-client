//
//  DataManager.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import FirebaseAuth
import ostelco_core
import PromiseKit

class UserManager: TokenProvider {
    enum Error: Swift.Error {
        case noFirebaseUser
    }
    
    static let shared = UserManager()
    
    var customer: CustomerModel? {
        didSet {
            guard let customer = self.customer else {
                Freshchat.sharedInstance().resetUser(completion: { () in
                    //Completion code
                })
                Crashlytics.sharedInstance().setUserIdentifier(nil)
                return
            }
            
            Freshchat.sharedInstance().identifyUser(withExternalID: customer.id, restoreID: nil)
            let fcUser = FreshchatUser.sharedInstance()
            fcUser?.firstName = customer.name
            fcUser?.email = customer.email
            Freshchat.sharedInstance().setUser(fcUser)
            
            Crashlytics.sharedInstance().setUserIdentifier(customer.id)
            Crashlytics.sharedInstance().setUserName(customer.name)
            Crashlytics.sharedInstance().setUserEmail(customer.email)
        }
    }
    
    private var firebaseUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    var hasCurrentUser: Bool {
        return self.firebaseUser != nil
    }
    
    var currentUserEmail: String? {
        return self.firebaseUser?.email
    }
        
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            ApplicationErrors.log(error)
        }
        
        self.customer = nil
        OnBoardingManager.sharedInstance.region = nil
    }
    
    func getDestinationFromContext() -> Promise<PostLoginDestination> {
        return APIManager.shared.primeAPI.loadContext()
            .map { context -> PostLoginDestination in
                UserManager.shared.customer = context.customer
                guard let region = context.getRegion() else {
                    return .validateCountry
                }
                
                return self.handleRegionResponse(region)
            }
            // Recover allows us to check for an error but continue the chain
            .recover { error -> Promise<PostLoginDestination> in
                switch error {
                case APIHelper.Error.invalidResponseCode(let code, _):
                    if code == 404 {
                        return .value(.signupStart)
                    } // else, keep going.
                case APIHelper.Error.jsonError(let requestError):
                    if requestError.httpStatusCode == 404 {
                        return .value(.signupStart)
                    } // else, keep going.
                default:
                    break
                }
                
                // Re-throw the error if we got here.
                throw error
            }
    }
    
    private func handleRegionResponse(_ region: RegionResponse) -> PostLoginDestination {
        OnBoardingManager.sharedInstance.region = region
        switch region.status {
        case .PENDING:
            if let jumio = region.kycStatusMap.JUMIO,
                let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER,
                let nricFin = region.kycStatusMap.NRIC_FIN {
                switch (jumio, addressAndPhoneNumber, nricFin) {
                case (.APPROVED, .APPROVED, .APPROVED):
                    return .ekycLastScreen
                case (.REJECTED, _, _):
                    return .ekycOhNo
                case (.PENDING, .APPROVED, .APPROVED):
                    return .esimSetup
                default:
                    return .validateCountry
                }
            } else {
                return .validateCountry
            }
        case .APPROVED:
            // TODO: Redirect based on sim profiles in region
            guard let simProfile = region.getSimProfile() else {
                return .esimSetup
            }
            
            switch simProfile.status {
            // TODO: NOT_READY should probably send user to one of our error screens
            case .AVAILABLE_FOR_DOWNLOAD,
                 .NOT_READY:
                return .esimSetup
            default:
                return .home
            }
        case .REJECTED:
            return .ekycOhNo
        }
    }
    
    func deleteAccount(showingIn viewController: UIViewController) {
        let spinnerView = viewController.showSpinner(onView: viewController.view)
        APIManager.shared.primeAPI.deleteCustomer()
            .ensure { [weak viewController] in
                viewController?.removeSpinner(spinnerView)
            }
            .done { [weak viewController] in
                self.logOut() // no `weak self` since this is a singleton.
                guard let vc = viewController else {
                    // Not worth instantiating the splash VC.
                    return
                }
                
                let splashVC = SplashViewController.fromStoryboard()
                vc.present(splashVC, animated: true)
            }
            .catch { [weak viewController] error in
                ApplicationErrors.log(error)
                viewController?.showGenericError(error: error)
            }
    }
    
    // MARK: - TokenProvider
    
    func getToken() -> Promise<String> {
        guard let user = self.firebaseUser else {
            return Promise(error: Error.noFirebaseUser)
        }

        return user.promiseGetIDToken()
    }
    
    func forceRefreshToken() -> Promise<String> {
        guard let user = self.firebaseUser else {
            return Promise(error: Error.noFirebaseUser)
        }
        
        return user.promiseGetIDToken(forceRefresh: true)
    }
}
