//
//  AllowLocationAccessViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core
import OstelcoStyles
import UIKit

class AllowLocationAccessViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: BodyTextLabel!
    
    /// For the `LocationChecking` protocol
    var spinnerView: UIView?
    
    private var hasRequestedAuthorization = false
    
    // These are set in viewDidLoad
    // swiftlint:disable implicitly_unwrapped_optional
    private var selectedCountry: Country!
    private var linkableText: LinkableText!
    // swiftlint:enable implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
        self.linkableText = self.generateLinkableText(for: self.selectedCountry)
        self.descriptionLabel.tapDelegate = self
        self.descriptionLabel.setLinkableText(self.linkableText)
    }
    
    func generateLinkableText(for country: Country) -> LinkableText? {
        return LinkableText(fullText: "To give you mobile data, by law, we have to verify that you’re in \(country.nameOrPlaceholder)",
                            linkedPortion: "by law")
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

extension AllowLocationAccessViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .country
    }
    
    static var isInitialViewController: Bool {
        return false
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

extension AllowLocationAccessViewController: LabelTapDelegate {
    
    func tappedAttributedLabel(_ label: UILabel, at characterIndex: Int) {
        guard self.linkableText.isIndexLinked(characterIndex) else {
            return
        }
        
        UIApplication.shared.open(ExternalLink.locationRequirement.url)
    }
}
