//
//  EKYCCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Netverify
import ostelco_core

protocol EKYCCoordinatorDelegate: class {
    func reselectCountry()
    func ekycSuccessful(region: RegionResponse)
}

protocol EKYCCoordinator: class {
    var delegate: EKYCCoordinatorDelegate? { get set }
    var navigationController: UINavigationController { get }
    var country: Country { get }
    var apiManager: APIManager { get }
    var jumioCoordinator: JumioCoordinator? { get set }
    
    func showFirstStepAfterLanding()
    func ekycRejectedRetryHandler()
}

extension EKYCCoordinator {
    
    // NOTE: This must be called on one of the concrete implementations of EKYCCoordinator
    static func forCountry(country: Country,
                           apiManager: APIManager = .shared,
                           navigationController: UINavigationController) -> EKYCCoordinator {
        switch country.countryCode.lowercased() {
        case "sg":
            return SingaporeEKYCCoordinator(navigationController: navigationController,
                                            apiManager: apiManager)
        default:
            return DefaultEKYCCoordinator(navigationController: navigationController,
                                          apiManager: apiManager,
                                          country: country)
        }
    }
    
    func showEKYCLandingPage(animated: Bool) {
        let verifyOnboarding = VerifyIdentityOnBoardingViewController.fromStoryboard()
        verifyOnboarding.coordinator = self
        self.navigationController.setViewControllers([verifyOnboarding], animated: animated)
    }
    
    func showEKYCRejectedPage(animated: Bool) {
        let ohNo = OhNoViewController.fromStoryboard(type: .ekycRejected)
        ohNo.primaryButtonAction = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.ekycRejectedRetryHandler()
        }
        
        self.navigationController.setViewControllers([ohNo], animated: animated)
    }
    
    func showWaitingForVerification(animated: Bool) {
        let waitingVC = PendingVerificationViewController.fromStoryboard()
        self.navigationController.setViewControllers([waitingVC], animated: animated)
    }
}

extension EKYCCoordinator where Self: JumioCoordinatorDelegate {
    
    func launchJumio(apiManager: APIManager, animated: Bool) {
        let jumioCoordinator: JumioCoordinator
        do {
            jumioCoordinator = try JumioCoordinator(country: country, apiManager: apiManager)
        } catch let error {
            self.handleError(message: error.localizedDescription)
            return
        }
        
        jumioCoordinator.startScan(from: self.navigationController)
        self.jumioCoordinator = jumioCoordinator
    }
    
    func handleError(message: String) {
        self.navigationController.showAlert(title: "Error", msg: message)
    }
}
