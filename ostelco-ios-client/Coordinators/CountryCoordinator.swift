//
//  CountryCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UIKit

protocol CountryCoordinatorDelegate: class {
    func countrySelectionCompleted()
}

class CountryCoordinator {
    enum Destination {
        case landing
        case chooseCountry
        case allowLocation
        case locationProblem(_ problem: LocationProblem)
        case countryComplete
    }
    
    private let navigationController: UINavigationController
    private let locationController: LocationController
    weak var delegate: CountryCoordinatorDelegate?
    private var spinnerView: UIView?
    
    init(navigationController: UINavigationController,
         locationController: LocationController = .shared) {
        self.navigationController = navigationController
        self.locationController = locationController
    }
    
    func determineDestination(hasSeenInitalVC: Bool = false, selectedCountry: Country? = nil) -> Promise<CountryCoordinator.Destination> {
        guard hasSeenInitalVC else {
            return .value(.landing)
        }
        
        guard let country = selectedCountry else {
            return .value(.chooseCountry)
        }
        
        switch self.locationController.authorizationStatus {
        case .notDetermined:
            return .value(.allowLocation)
        case .restricted:
            return .value(.locationProblem(.restrictedByParentalControls))
        case .denied:
            return .value(.locationProblem(.deniedByUser))
        case .authorizedAlways,
             .authorizedWhenInUse:
            // Keep going
            break
        @unknown default:
            ApplicationErrors.assertAndLog("Apple added a new case here!")
        }
        
        var isDebug = false
        #if ENABLE_SKIP_USER_LOCATION_CHECK
            isDebug = true
        #endif
        
        self.spinnerView = self.navigationController.showSpinner(onView: self.navigationController.view, loadingText: "Checking location...")
        return self.locationController.checkInCorrectCountry(country, isDebug: isDebug)
            .map {
                // If no error occurred, this is the correct location!
                return .countryComplete
            }
            .ensure { [weak self] in
                // Whether we get an error or success, we always want to kill the spinner.
                self?.navigationController.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .recover { error -> Promise<CountryCoordinator.Destination> in
                switch error {
                case LocationController.Error.locationProblem(let problem):
                    let destination = CountryCoordinator.Destination.locationProblem(problem)
                    return .value(destination)
                default:
                    // Handled below
                    break
                }
                
                throw error
            }
    }
    
    func navigate(to destination: CountryCoordinator.Destination, animated: Bool) {
        switch destination {
        case .allowLocation:
            let allowLocation = AllowLocationAccessViewController.fromStoryboard()
            allowLocation.coordinator = self
            self.navigationController.setViewControllers([allowLocation], animated: animated)
        case .chooseCountry:
            let chooseCountry = ChooseCountryViewController.fromStoryboard()
            chooseCountry.coordinator = self
            self.navigationController.setViewControllers([chooseCountry], animated: animated)
        case .landing:
            let landing = VerifyCountryOnBoardingViewController.fromStoryboard()
            landing.coordinator = self
            self.navigationController.setViewControllers([landing], animated: animated)
        case .locationProblem(let problem):
            self.handleLocationProblem(problem)
        case .countryComplete:
            self.delegate?.countrySelectionCompleted()
        }
    }
    
    func finishedViewingCountryLandingScreen() {
        self.determineDestination(hasSeenInitalVC: true, selectedCountry: nil)
            .done { [weak self] destination in
                self?.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func selectedCountry(_ country: Country) {
        OstelcoAnalytics.logEvent(.ChosenCountry(country: country))
        OnBoardingManager.sharedInstance.selectedCountry = country
        self.determineDestination(hasSeenInitalVC: true, selectedCountry: country)
            .done { destination in
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func handleLocationProblem(_ problem: LocationProblem, animated: Bool = true) {
        let problemVC = LocationProblemViewController.fromStoryboard()
        problemVC.locationProblem = problem
        problemVC.coordinator = self
        self.navigationController.setViewControllers([problemVC], animated: animated)
    }
    
    func locationUsageAuthorized(for country: Country) {
        self.determineDestination(hasSeenInitalVC: true, selectedCountry: country)
            .done { destination in
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
}
