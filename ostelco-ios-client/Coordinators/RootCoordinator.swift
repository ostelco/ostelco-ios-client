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

enum RootDestination {
    case login
    case email
    case signUp
    case country
    case ekyc(region: RegionResponse)
    case esim(profile: SimProfile?)
    case home
}

class RootCoordinator {
    
    let window: UIWindow
    
    private var noInternetVC: UIViewController?
    private lazy var onboardingNavController = UINavigationController()
    
    private var signUpCoordinator: SignUpCoordinator?
    private var countryCoordinator: CountryCoordinator?
    private var ekycCoordinator: EKYCCoordinator?
    private var esimCoordinator: ESimCoordinator?
    
    init(window: UIWindow) {
        self.window = window
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
    
    func determineDestination() -> Promise<RootDestination> {
        guard UserManager.shared.hasCurrentUser else {
            // NOPE! We need to log in.
            return .value(.login)
        }
        
        return APIManager.shared.primeAPI.loadContext()
            .map { context -> RootDestination in
                UserManager.shared.customer = context.customer
                guard let region = context.getRegion() else {
                    return .country
                }
                
                OnBoardingManager.sharedInstance.region = region
                return self.handleRegionResponse(region)
            }
            // Recover allows us to check for an error but continue the chain
            .recover { error -> Promise<RootDestination> in
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
    
    func handleRegionResponse(_ region: RegionResponse) -> RootDestination {
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
    
    func navigate(to destination: RootDestination,
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
            guard let emailNav = Storyboard.email.asUIStoryboard.instantiateInitialViewController() else {
                ApplicationErrors.assertAndLog("Could not instantiate email nav!")
                return
            }
            
            self.topViewController?.present(emailNav, animated: animated)
        case .signUp:
            let coordinator = SignUpCoordinator(navigationController: self.onboardingNavController)
            coordinator.delegate = self
            let destination = coordinator.determineDestination()
            coordinator.navigate(to: destination, animated: animated)
            self.signUpCoordinator = coordinator
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
        case .ekyc(let region):
            let coordinator =
                DefaultEKYCCoordinator.forCountry(country: region.region.country, navigationController: self.onboardingNavController)
            coordinator.showEKYCLandingPage(animated: animated)
            self.ekycCoordinator = coordinator
        case .esim(let profile):
            let coordinator = ESimCoordinator()
            let destination = coordinator.determineDestination(from: profile)
            coordinator.navigate(to: destination)
            self.esimCoordinator = coordinator
        case .home:
            let tabs = TabBarController.fromStoryboard()
            presentingViewController.present(tabs, animated: animated)
        }
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

// MARK: - SignUpCoordinatorDelegate

extension RootCoordinator: SignUpCoordinatorDelegate {
    
    func signUpCompleted() {
        self.navigate(to: .country, from: nil, animated: true)
        self.signUpCoordinator = nil
    }
}

// MARK: - CountryCoordinatorDelegate

extension RootCoordinator: CountryCoordinatorDelegate {
    
    func countrySelectionCompleted() {
        self.determineDestination()
            .done { [weak self] destination in
                self?.navigate(to: destination, from: nil, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
                // TODO: What do we do if this didn't work?
            }
    }
}
