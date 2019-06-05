//
//  RootCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UIKit

class RootCoordinator {
    
    enum Destination {
        case login
        case email
        case signUp
        case country
        case ekyc(region: RegionResponse?)
        case esim(profile: SimProfile?)
        case home
    }
    
    let window: UIWindow
    
    private var noInternetVC: UIViewController?
    private lazy var onboardingNavController: UINavigationController = {
        let nav = UINavigationController()
        nav.isNavigationBarHidden = true
        return nav
    }()
    
    private var emailCoordinator: EmailCoordinator?
    private var signUpCoordinator: SignUpCoordinator?
    private var countryCoordinator: CountryCoordinator?
    private var ekycCoordinator: EKYCCoordinator?
    private var esimCoordinator: ESimCoordinator?
    
    private let userManager: UserManager
    
    init(window: UIWindow,
         userManager: UserManager = .shared) {
        self.window = window
        self.userManager = userManager
    }
    
    var topViewController: UIViewController? {
        return self.window.rootViewController?.topPresentedViewController()
    }
    
    func replaceRootViewController(with newRoot: UIViewController) {
        self.window.rootViewController = newRoot
    }
    
    func determineAndNavigateToInitialDestination(animated: Bool = true) {
        self.determineDestination()
            .done { [weak self] destination in
                self?.navigate(to: destination, from: nil, animated: animated)
            }
            .catch { error in
                ApplicationErrors.log(error)
                // TODO: Figure out how to deal with this failing.
            }
    }
    
    func determineDestination() -> Promise<RootCoordinator.Destination> {
        guard self.userManager.hasCurrentUser else {
            // NOPE! We need to log in.
            return .value(.login)
        }
        
        guard UserDefaultsWrapper.pendingEmail == nil else {
            // We still need to confirm the user's email
            return .value(.email)
        }
        
        return APIManager.shared.primeAPI
            .loadContext()
            .map { context -> RootCoordinator.Destination in
                self.userManager.customer = context.customer
                guard let region = context.getRegion() else {
                    return .country
                }
                
                OnBoardingManager.sharedInstance.region = region
                return self.handleRegionResponse(region)
            }
            // Recover allows us to check for an error but continue the chain
            .recover { error -> Promise<RootCoordinator.Destination> in
                switch error {
                case APIHelper.Error.invalidResponseCode(let code, _):
                    if code == 404 {
                        return .value(.signUp)
                    } // else, keep going.
                case APIHelper.Error.jsonError(let requestError):
                    if requestError.httpStatusCode == 404 {
                        return .value(.signUp)
                    } // else, keep going.
                default:
                    break
                }
                
                // Re-throw the error if we got here.
                throw error
            }
    }
    
    func handleRegionResponse(_ region: RegionResponse) -> RootCoordinator.Destination {
        switch region.status {
        case .PENDING:
            return .ekyc(region: region)
        case .APPROVED:
            guard let simProfile = region.getSimProfile() else {
                return .esim(profile: nil)
            }
            
            switch simProfile.status {
            case .AVAILABLE_FOR_DOWNLOAD,
                 .NOT_READY:
                // Something needs to happen with the profile, kick to that coordinator.
                return .esim(profile: simProfile)
            default:
                // We're already set up, just show the main screen.
                return .home
            }
        case .REJECTED:
            return .ekyc(region: region)
        }
    }
    
    func navigate(to destination: RootCoordinator.Destination,
                  from viewController: UIViewController?,
                  animated: Bool) {
        let presentingViewController: UIViewController
        if let passedInVC = viewController {
            presentingViewController = passedInVC
        } else if let topVC = self.topViewController {
            presentingViewController = topVC
        } else {
            ApplicationErrors.assertAndLog("No view controller?!")
            return
        }
        
        switch destination {
        case .login:
            let loginViewController = LoginViewController.fromStoryboard()
            self.topViewController?.present(loginViewController, animated: animated)
        case .email:
            let coordinator = EmailCoordinator(navigationController: self.onboardingNavController)
            coordinator.delegate = self
            let hasEnteredEmail = (UserDefaultsWrapper.pendingEmail != nil)
            let destination = coordinator.determineDestination(emailEntered: hasEnteredEmail)
            coordinator.navigate(to: destination, animated: animated)
            self.emailCoordinator = coordinator
            self.presentOnboardingNavIfNotAlreadyShowing(from: presentingViewController, animated: animated)
        case .signUp:
            let coordinator = SignUpCoordinator(navigationController: self.onboardingNavController)
            coordinator.delegate = self
            coordinator.determineDestination()
                .done { destination in
                    coordinator.navigate(to: destination, animated: animated)
                }
                .catch { error in
                    ApplicationErrors.log(error)
                }
            self.signUpCoordinator = coordinator
            self.presentOnboardingNavIfNotAlreadyShowing(from: presentingViewController, animated: animated)
        case .country:
            let coordinator = CountryCoordinator(navigationController: self.onboardingNavController)
            coordinator.delegate = self
            coordinator.determineDestination()
                .done { destination in
                    coordinator.navigate(to: destination, animated: animated)
                }
                .catch { error in
                    ApplicationErrors.log(error)
                }
            self.countryCoordinator = coordinator
            self.presentOnboardingNavIfNotAlreadyShowing(from: presentingViewController, animated: animated)
        case .ekyc(let region):
            let country: Country
            if let regionCountry = region?.region.country {
                country = regionCountry
            } else {
                country = OnBoardingManager.sharedInstance.selectedCountry
            }
            
            let coordinator = DefaultEKYCCoordinator.forCountry(country: country, navigationController: self.onboardingNavController)
            coordinator.determineAndNavigateDestination(from: region, animated: animated)
            coordinator.delegate = self
            self.ekycCoordinator = coordinator
            self.presentOnboardingNavIfNotAlreadyShowing(from: presentingViewController, animated: animated)
        case .esim(let profile):
            let coordinator = ESimCoordinator(navigationController: self.onboardingNavController)
            coordinator.delegate = self
            let destination = coordinator.determineDestination(from: profile)
            coordinator.navigate(to: destination, animated: animated)
            self.esimCoordinator = coordinator
            self.presentOnboardingNavIfNotAlreadyShowing(from: presentingViewController, animated: animated)
        case .home:
            let tabs = TabBarController.fromStoryboard()
            presentingViewController.present(tabs, animated: animated)
        }
    }
    
    private func presentOnboardingNavIfNotAlreadyShowing(from presentingViewController: UIViewController, animated: Bool) {
        guard self.onboardingNavController.presentingViewController == nil else {
            // already presented, it'll crash if we try again.
            return
        }
     
        presentingViewController.present(self.onboardingNavController, animated: animated)
    }
    
    func showNoInternet() {
        guard self.noInternetVC == nil else {
            // Already showing
            return
        }
        
        let noInternet = OhNoViewController.fromStoryboard(type: .noInternet)
        noInternet.primaryButtonAction = {
            guard InternetConnectionMonitor.shared.isCurrentlyConnected() else {
                // Still no internet for you.
                return
            }
            
            self.hideNoInternet()
        }
        
        self.noInternetVC = noInternet
        self.topViewController?.present(noInternet, animated: true)
    }
    
    func hideNoInternet() {
        guard let vc = self.noInternetVC else {
            // Nothing to hide
            return
        }
        
        self.noInternetVC = nil
        vc.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EmailCoordinatorDelegate

extension RootCoordinator: EmailCoordinatorDelegate {
    
    func emailSuccessfullyVerified() {
        self.navigate(to: .country, from: nil, animated: true)
        self.emailCoordinator = nil
    }
}

// MARK: - SignUpCoordinatorDelegate

extension RootCoordinator: SignUpCoordinatorDelegate {
    
    func signUpCompleted() {
        self.navigate(to: .country, from: nil, animated: true)
        self.signUpCoordinator = nil
    }
}

// MARK: - CountryCoordinatorDelegate

extension RootCoordinator: CountryCoordinatorDelegate {
    
    func countrySelectionCompleted(with country: Country) {
        self.navigate(to: .ekyc(region: nil), from: nil, animated: true)
        self.countryCoordinator = nil
    }
}

// MARK: - EKYCCoordinatorDelegate

extension RootCoordinator: EKYCCoordinatorDelegate {
    
    func ekycSuccessful(region: RegionResponse) {
        self.navigate(to: .esim(profile: region.getSimProfile()), from: nil, animated: true)
        self.ekycCoordinator = nil
    }
    
    func reselectCountry() {
        self.navigate(to: .country, from: nil, animated: true)
        self.ekycCoordinator = nil
    }
}

// MARK: - ESimCoordinatorDelegate

extension RootCoordinator: ESimCoordinatorDelegate {
    
    func esimSetupComplete() {
        self.navigate(to: .home, from: nil, animated: true)
        self.esimCoordinator = nil
    }
}
