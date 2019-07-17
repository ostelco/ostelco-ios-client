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

protocol AllowLocationAccessDelegate: class {
    func handleLocationProblem(_ problem: LocationProblem)
    func locationUsageAuthorized(for country: Country)
}

class AllowLocationAccessViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: BodyTextLabel!
    
    weak var delegate: AllowLocationAccessDelegate?

    /// For the `LocationChecking` protocol
    var spinnerView: UIView?
    
    private var hasRequestedAuthorization = false
    
    private var selectedCountry: Country!
    private var linkableText: LinkableText!
    
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
    
    private func requestAuthorization() {
        let locationController = LocationController.shared
        guard locationController.locationServicesEnabled else {
            self.delegate?.handleLocationProblem(.disabledInSettings)
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
            self.delegate?.handleLocationProblem(.restrictedByParentalControls)
        case .denied:
            self.delegate?.handleLocationProblem(.deniedByUser)
        case .authorizedAlways,
             .authorizedWhenInUse:
            self.delegate?.locationUsageAuthorized(for: self.selectedCountry)
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

extension AllowLocationAccessViewController: LabelTapDelegate {
    
    func tappedAttributedLabel(_ label: UILabel, at characterIndex: Int) {
        guard self.linkableText.isIndexLinked(characterIndex) else {
            return
        }
        
        UIApplication.shared.open(ExternalLink.locationRequirement.url)
    }
}
