//
//  SignUpCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UserNotifications
import UIKit

protocol SignUpCoordinatorDelegate: class {
    /// Called when sign up is completed and the next step must be shown.
    func signUpCompleted()
}

class SignUpCoordinator {
    enum Destination {
        case legalese
        case enterName
        case allowPushNotifications
        case signupComplete
    }
    
    let userManager: UserManager
    let notificationController: PushNotificationController
    let navigationController: UINavigationController
    weak var delegate: SignUpCoordinatorDelegate?
    
    init(navigationController: UINavigationController,
         userManager: UserManager = .shared,
         notificationController: PushNotificationController = .shared) {
        self.navigationController = navigationController
        self.userManager = userManager
        self.notificationController = notificationController
    }
    
    func determineDestination(isLegaleseAgreed: Bool = false) -> Promise<SignUpCoordinator.Destination> {
        guard isLegaleseAgreed else {
            return .value(.legalese)
        }
        
        guard self.userManager.customer != nil else {
            return .value(.enterName)
        }
        
        return self.notificationController.getAuthorizationStatus()
            .map { authorizationStatus in
                switch authorizationStatus {
                case .notDetermined,
                     .provisional:
                    // Either of these we should actively prompt the user.
                    return .allowPushNotifications
                case .denied,
                     .authorized:
                    // Either of these, we're done - they already said yes or no.
                    return .signupComplete
                @unknown default:
                    ApplicationErrors.assertAndLog("Apple added a new case, you should update this code!")
                    // This is probably something where we should still at least try to ask for permissions
                    return .allowPushNotifications
                }
            }
    }
    
    func navigate(to destination: SignUpCoordinator.Destination, animated: Bool) {
        switch destination {
        case .legalese:
            let legalVC = TheLegalStuffViewController.fromStoryboard()
            legalVC.delegate = self
            self.navigationController.setViewControllers([legalVC], animated: animated)
        case .enterName:
            let nameVC = GetStartedViewController.fromStoryboard()
            nameVC.delegate = self
            self.navigationController.setViewControllers([nameVC], animated: animated)
        case .allowPushNotifications:
            let pushVC = EnableNotificationsViewController.fromStoryboard()
            pushVC.delegate = self
            self.navigationController.setViewControllers([pushVC], animated: animated)
        case .signupComplete:
            self.delegate?.signUpCompleted()
        }
    }
    
    private func determineDestinationAndNavigate() {
        self.determineDestination(isLegaleseAgreed: true)
            .done { destination in
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
}

extension SignUpCoordinator: TheLegalStuffDelegate {
    func legaleseAgreed() {
        self.determineDestinationAndNavigate()
    }
}

extension SignUpCoordinator: GetStartedDelegate {
    func nameEnteredSuccessfully() {
        self.determineDestinationAndNavigate()
    }
}

extension SignUpCoordinator: EnableNotificationsDelegate {
    func pushAgreedOrDenied() {
        self.determineDestinationAndNavigate()
    }
}
