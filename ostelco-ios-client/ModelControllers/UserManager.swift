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
        UserDefaultsWrapper.clearAll()
    }
    
    func deleteAccount(showingIn viewController: UIViewController) {
        let spinnerView = viewController.showSpinner(onView: viewController.view)
        APIManager.shared.primeAPI.deleteCustomer()
            .ensure { [weak viewController] in
                viewController?.removeSpinner(spinnerView)
            }
            .done {
                self.logOut() // no `weak self` since this is a singleton.
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
