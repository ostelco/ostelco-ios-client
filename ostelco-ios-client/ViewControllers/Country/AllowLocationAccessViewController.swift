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
    func locationUsageAuthorized()
}

class AllowLocationAccessViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: BodyTextLabel!
    
    weak var delegate: AllowLocationAccessDelegate!
    
    var spinnerView: UIView?
    
    private var hasRequestedAuthorization = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.tapDelegate = self
        descriptionLabel.setLinkableText(
            LinkableText(
                fullText: NSLocalizedString("To give you mobile data, by law, we have to verify which country you're in", comment: "Explanation for location permissions before user is prompted."),
                linkedPortion: Link(
                    NSLocalizedString("by law", comment: "Explanation for location permissions before user is prompted: linkable part"),
                    url: ExternalLink.oyaWebpage.url
                )
            )!
        )
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        requestAuthorization()
        hasRequestedAuthorization = true
    }
    
    private func requestAuthorization() {
        let locationController = LocationController.shared
        guard locationController.locationServicesEnabled else {
            delegate.handleLocationProblem(.disabledInSettings)
            return
        }
        
        let status = LocationController.shared.authorizationStatus
        handleAuthorizationStatus(status)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            LocationController.shared.requestAuthorization()
            LocationController.shared.authChangeCallback = { [weak self] status in
                self?.handleAuthorizationStatus(status)
            }
        case .restricted:
            delegate.handleLocationProblem(.restrictedByParentalControls)
        case .denied:
            delegate.handleLocationProblem(.deniedByUser)
        case .authorizedAlways,
             .authorizedWhenInUse:
            delegate.locationUsageAuthorized()
        @unknown default:
            ApplicationErrors.assertAndLog("Apple added another case to this! You should update your handling.")
        }
    }
}

extension AllowLocationAccessViewController: LabelTapDelegate {
    func tappedLink(_ link: Link) {
        UIApplication.shared.open(link.url, options: [:], completionHandler: nil)
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
