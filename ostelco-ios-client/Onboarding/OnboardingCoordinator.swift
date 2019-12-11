//
//  RootCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import PromiseKit
import UIKit
import FirebaseAuth
import UserNotifications
import CoreLocation
import CoreTelephony

protocol OnboardingCoordinatorDelegate: class {
    func onboardingComplete()
}

public protocol Authorization {
    func addStateDidChangeListener(_ listener: @escaping AuthStateDidChangeListenerBlock) -> AuthStateDidChangeListenerHandle
    func removeStateDidChangeListener(_ listenerHandle: AuthStateDidChangeListenerHandle)
}

extension Auth: Authorization {}

class OnboardingCoordinator {
    weak var delegate: OnboardingCoordinatorDelegate?
    
    var localContext = OnboardingContext()
    let stageDecider = StageDecider()
    let primeAPI: PrimeAPI
    let auth: Authorization
    let location: LocationController
    let notifications: PushNotificationController
    
    var listenerHandle: AuthStateDidChangeListenerHandle?
    
    let navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController,
        primeAPI: PrimeAPI = APIManager.shared.primeAPI,
        notifications: PushNotificationController = PushNotificationController.shared,
        auth: Authorization = Auth.auth(),
        location: LocationController = LocationController.shared
    ) {
        self.navigationController = navigationController
        self.primeAPI = primeAPI
        self.auth = auth
        self.location = location
        self.notifications = notifications
        
        listenerHandle = auth.addStateDidChangeListener { (_, user) in
            self.localContext.hasFirebaseToken = user != nil
            self.advance()
        }
        
        notifications.getAuthorizationStatus()
        .done { (status) in
            self.localContext.hasSeenNotificationPermissions = status != .notDetermined
        }.cauterize()
        
        location.startUpdatingLocation()
    }
    
    deinit {
        if let handle = listenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    
    func advance() {
        primeAPI.loadContext()
            .done { (context) in
                assert(Thread.isMainThread)
                
                self.localContext.serverIsUnreachable = false
                self.localContext.hasSeenLocationPermissions = self.location.authorizationStatus != .notDetermined
                self.localContext.locationProblem = self.location.locationProblem
                
                UserManager.shared.customer = context.customer
                let stage = self.stageDecider.compute(context: context.toLegacyModel(), localContext: self.localContext)
                if stage == .home {
                    self.delegate?.onboardingComplete()
                } else {
                    self.afterDismissing {
                        self.navigateTo(stage)
                    }
                }
        }.recover { error in
            self.localContext.serverIsUnreachable = (error as NSError).code == -1004
            let context: Context? = nil
            let stage = self.stageDecider.compute(context: context, localContext: self.localContext)
            self.afterDismissing {
                self.navigateTo(stage)
            }
        }
    }
    
    private func afterDismissing(completion: @escaping () -> Void) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    private func navigateTo(_ stage: StageDecider.Stage) {
        assert(Thread.isMainThread)
        
        switch stage {
        case .loginCarousel:
            let loginViewController = LoginViewController.fromStoryboard()
            loginViewController.delegate = self
            navigationController.setViewControllers([loginViewController], animated: true)
        case .legalStuff:
            let legalStuff = TheLegalStuffViewController.fromStoryboard()
            legalStuff.delegate = self
            navigationController.setViewControllers([legalStuff], animated: true)
        case .nicknameEntry:
            let nicknameEntry = GetStartedViewController.fromStoryboard()
            nicknameEntry.delegate = self
            navigationController.setViewControllers([nicknameEntry], animated: true)
        case .home:
            delegate?.onboardingComplete()
        case .ohNo(let issue):
            let ohNo = OhNoViewController.fromStoryboard(type: issue)
            ohNo.primaryButtonAction = { [weak self] in
                self?.advance()
            }
            navigationController.present(ohNo, animated: true, completion: nil)
        case .locationPermissions:
            let locationPermissions = AllowLocationAccessViewController.fromStoryboard()
            locationPermissions.delegate = self
            navigationController.setViewControllers([locationPermissions], animated: true)
        case .locationProblem(let problem):
            let locationProblem = LocationProblemViewController.fromStoryboard()
            locationProblem.delegate = self
            locationProblem.locationProblem = problem
            navigationController.setViewControllers([locationProblem], animated: true)
        case .notificationPermissions:
            let notificationPermissions = EnableNotificationsViewController.fromStoryboard()
            notificationPermissions.delegate = self
            navigationController.setViewControllers([notificationPermissions], animated: true)
        }
    }
}

extension OnboardingCoordinator: LoginDelegate {
    enum FirebaseError: Swift.Error, LocalizedError {
        case noErrorAndNoUser
        
        var localizedDescription: String {
            switch self {
            case .noErrorAndNoUser:
                return NSLocalizedString("Signed into Firebase and received neither a user nor an error!", comment: "Error case during firebase auth when we could not get a user.")
            }
        }
    }
    
    func signedIn(controller: UIViewController, authCode: String, contactEmail: String?) {
        let spinnerView = controller.showSpinner()
        
        UserDefaultsWrapper.contactEmail = contactEmail
        let appleIdToken = AppleIdToken(authCode: authCode)
        primeAPI.authorizeAppleId(with: appleIdToken)
            .then { (customToken) -> PromiseKit.Promise<Void> in
                debugPrint("customToken ", customToken.token, contactEmail ?? "")
                return self.signInWithCustomToken(customToken: customToken.token)
        }
        // The callback for Auth.auth().addStateDidChangeListener() will call advance().
        .catch { error in
            debugPrint("Authorize Error :", error)
            ApplicationErrors.log(error)
            controller.removeSpinner(spinnerView)
            controller.showAlert(
                title: NSLocalizedString("Sign In Error", comment: "Title for alert when authorize Apple Id fails."),
                msg: NSLocalizedString("Failed to authorize user, please try again or contact customer support.", comment: "Message for alert when authorize Apple Id fails.")
            )
        }
    }
    
    func signInError(controller: UIViewController, error: Error) {
        debugPrint("Sign In Error :", error)
        ApplicationErrors.log(error)
        controller.showAlert(
            title: NSLocalizedString("Apple Sign In Error", comment: "Title for alert when Sign In with Apple fails."),
            msg: NSLocalizedString("Sign In with Apple Failed, please try again or contact customer support.", comment: "Message for alert when Sign In with Apple fails.")
        )
    }
    
    func signInWithCustomToken(customToken: String) -> Promise<Void> {
        return Promise { seal in
            Auth.auth().signIn(withCustomToken: customToken) { authDataResult, error in
                if let firebaseError = error {
                    seal.reject(firebaseError)
                    return
                }
                guard authDataResult?.user != nil else {
                    seal.reject(FirebaseError.noErrorAndNoUser)
                    return
                }
                
                seal.fulfill(())
            }
        }
    }
}

extension OnboardingCoordinator: TheLegalStuffDelegate {
    func legaleseAgreed() {
        localContext.hasAgreedToTerms = true
        advance()
    }
}

extension OnboardingCoordinator: GetStartedDelegate {
    func enteredNickname(controller: UIViewController, nickname: String) {
        let spinnerView = controller.showSpinner()
        guard let email = UserManager.shared.currentUserEmail else {
            controller.removeSpinner(spinnerView)
            controller.showAlert(
                title: NSLocalizedString("Error", comment: "Error message title"),
                msg: NSLocalizedString("Email is empty or missing in Firebase", comment: "Error message when we don't get info from Firebase")
            )
            return
        }
        
        let user = UserSetup(nickname: nickname, email: email)
        
        primeAPI.createCustomer(with: user)
            .done { [weak self] customer in
                UserManager.shared.customer = PrimeGQL.ContextQuery.Data.Context.Customer(legacyModel: customer)
                OstelcoAnalytics.logEvent(.signup)
                self?.advance()
        }
        .catch { error in
            debugPrint("createCustomer Error :", error)
            ApplicationErrors.log(error)
            controller.removeSpinner(spinnerView)
            controller.showGenericError(error: error)
        }
    }
}

extension OnboardingCoordinator: EnableNotificationsDelegate {
    func requestPermission() {
        notifications.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
        .ensure { [weak self] in
            self?.localContext.hasSeenNotificationPermissions = true
        }
        .done { [weak self] _ in
            self?.advance()
        }
        .catch { [weak self] error in
            switch error {
            case PushNotificationController.Error.notAuthorized:
                // The user declined push notifications. Oh well. Let's move on.
                self?.advance()
            default:
                ApplicationErrors.log(error)
                self?.navigationController.showGenericError(error: error)
            }
        }
    }
}

extension OnboardingCoordinator: AllowLocationAccessDelegate {
    func handleLocationProblem(_ problem: LocationProblem) {
        localContext.locationProblem = problem
        advance()
    }
    
    func locationUsageAuthorized() {
        localContext.hasSeenLocationPermissions = true
        advance()
    }
    
}

extension OnboardingCoordinator: LocationProblemDelegate {
    func retry() {
        // We'll be informed about other location problems being fixed,
        // but for this one, we just need to let the user pick their country
        // again.
        if case .authorizedButWrongCountry = localContext.locationProblem {
            localContext.locationProblem = nil
        }
        advance()
    }
}

