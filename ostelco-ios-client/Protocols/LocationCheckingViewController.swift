//
//  LocationCheckingViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

/// A protocol constrained to only working on UIViewControllers to give mix-in capability
/// to check that the user is in a specific country
protocol LocationChecking: UIViewController {

    /// The loading view to show while location is being checked
    var spinnerView: UIView? { get set }

    /// Checks that the user's current location is in the given country
    ///
    /// - Parameter country: The country to check for.
    ///                      In the default implementation, defaults to the onboarding manager's selected country.
    func checkLocation(isIn country: Country)

    /// Shows an alert to the user when an error occurred getting their location
    func showFailedToGetLocationAlert()
    
    /// Called when it has been verified that the user is in the proper country.
    func locationCheckSucceeded()
    
    /// Called when a location problem has occurred.
    ///
    /// - Parameter problem: The problem which has occurred.
    func handleLocationProblem(_ problem: LocationProblem)
}

// MARK: - Default Implementation

extension LocationChecking {
    
    func showFailedToGetLocationAlert() {
        let alert = UIAlertController(title: "We're sorry but...", message: "We were unable to get your current location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkLocation(isIn country: Country = OnBoardingManager.sharedInstance.selectedCountry) {
        guard self.spinnerView == nil else {
            // We're already working on this.
            return
        }
        
        self.spinnerView = showSpinner(onView: view, loadingText: "Checking location...")
        var isDebug = false
        #if DEBUG
            isDebug = true
        #endif
        
        LocationController.shared.checkInCorrectCountry(country, isDebug: isDebug)
            .done { [weak self] in
                // Hooray, this is the correct location!
                self?.locationCheckSucceeded()
            }
            .ensure { [weak self] in
                // Whether we get an error or success, we always want to kill the spinner.
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .catch { [weak self] error in
                if let locationError = error as? LocationController.Error {
                    switch locationError {
                    case .locationProblem(let problem):
                        self?.handleLocationProblem(problem)
                        return
                    default:
                        // Handled below
                        break
                    }
                }
                
                debugPrint("- LocationChecking: Unable to get and/or reverse geocode location. Error: \(error)")
                self?.showFailedToGetLocationAlert()
        }
    }
}
