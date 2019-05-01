//
//  LocationProblemViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core
import UIKit

class LocationProblemViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var explanationLabel: UILabel!
    @IBOutlet private var primaryButton: UIButton!
    
    /// For the `LocationChecking` protocol
    var spinnerView: UIView?
    
    var locationProblem: LocationProblem? {
        didSet {
            self.configureForCurrentProblem()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureForCurrentProblem()
        self.listenForChanges()
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(applicationEnteredForeground),
                         name: UIApplication.willEnterForegroundNotification,
                         object: nil)
    }
    
    @objc private func applicationEnteredForeground() {
        switch self.locationProblem {
        case .disabledInSettings?:
            if LocationController.shared.locationServicesEnabled {
                LocationController.shared.requestAuthorization()
            }
        default:
            // Other situations should be handled by the permission change callback.
            break
        }
    }
    
    private func configureForCurrentProblem() {
        guard
            let problem = self.locationProblem,
            self.titleLabel != nil else {
                // Things aren't set up yet, please try your call again after ViewDidLoad.
                return
        }
        
        self.titleLabel.text = problem.title
        self.explanationLabel.text = problem.copy
        self.imageView.image = problem.image
        
        if let buttonTitle = problem.primaryButtonTitle {
            self.primaryButton.isHidden = false
            self.primaryButton.setTitle(buttonTitle, for: .normal)
        } else {
            self.primaryButton.isHidden = true
        }
    }
    
    @IBAction private func primaryButtonTapped() {
        guard let problem = self.locationProblem else {
            assertionFailure("You should have a problem by this point!")
            return
        }
        
        switch problem {
        case .notDetermined:
            LocationController.shared.requestAuthorization()
        case .disabledInSettings,
             .deniedByUser:
            UIApplication.shared.openSettings()
        case .authorizedButWrongCountry:
            // Re-check the user's location
            self.checkLocation()
        case .restrictedByParentalControls:
            assertionFailure("You shouldn't be able to get here, this button should be gone!")
        }
    }
    
    private func listenForChanges() {
        LocationController.shared.authChangeCallback = { [weak self] status in
            self?.handleAuthorzationStatusChange(to: status)
        }
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    private func handleAuthorzationStatusChange(to status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            self.locationProblem = .restrictedByParentalControls
        case .denied:
            self.locationProblem = .deniedByUser
        case .notDetermined:
            self.locationProblem = .notDetermined
        case .authorizedAlways,
             .authorizedWhenInUse:
            self.checkLocation()
        @unknown default:
            assertionFailure("Apple added a new status here! You should update this handling.")
        }
    }
}

// MARK: - StoryboardLoadable

extension LocationProblemViewController: StoryboardLoadable {
    static var isInitialViewController: Bool {
        return false
    }
    
    static var storyboard: Storyboard {
        return .country
    }
}

extension LocationProblemViewController: LocationChecking {
    
    func locationCheckSucceeded() {
        self.performSegue(withIdentifier: "locationAccessAllowedAndConfirmed", sender: self)
    }
    
    func handleLocationProblem(_ problem: LocationProblem) {
        self.locationProblem = problem
    }
}
