//
//  AllowLocationAccessViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreLocation
import ostelco_core

class AllowLocationAccessViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    /// For the `LocationChecking` protocol
    var spinnerView: UIView?
    
    private var hasRequestedAuthorization = false
    
    // This is set in viewDidLoad
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var selectedCountry: Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
        self.descriptionLabel.text = "We need to verify that you are in \(self.selectedCountry.name ?? "(Unknown)") in order to continue"
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        self.requestAuthorization()
        self.hasRequestedAuthorization = true
    }
    
    private func showLocationProblemViewController(for problem: LocationProblem) {
        let problemVC = LocationProblemViewController.fromStoryboard()
        problemVC.locationProblem = problem
        self.present(problemVC, animated: true)
    }
    
    private func requestAuthorization() {
        let locationController = LocationController.shared
        guard locationController.locationServicesEnabled else {
            self.showLocationProblemViewController(for: .disabledInSettings)
            return
        }
        
        let status = LocationController.shared.authorizationStatus
        self.handleAuthorizationStatus(status)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            LocationController.shared.requestAuthorization()
            LocationController.shared.authChangeCallback = { [weak self] status in
                self?.handleAuthorizationStatus(status)
            }
        case .restricted:
            self.showLocationProblemViewController(for: .restrictedByParentalControls)
        case .denied:
            self.showLocationProblemViewController(for: .deniedByUser)
        case .authorizedAlways,
             .authorizedWhenInUse:
            self.checkLocation()
        @unknown default:
            ApplicationErrors.assertAndLog("Apple added another case to this! You should update your handling.")
        }
    }
}

extension AllowLocationAccessViewController: LocationChecking {
    
    func locationCheckSucceeded() {
        self.performSegue(withIdentifier: "showEKYC", sender: self)
    }
    
    func handleLocationProblem(_ problem: LocationProblem) {
        self.showLocationProblemViewController(for: problem)
    }
}
