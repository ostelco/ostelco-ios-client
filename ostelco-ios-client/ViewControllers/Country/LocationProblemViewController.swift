//
//  LocationProblemViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import ostelco_core
import OstelcoStyles
import UIKit

protocol LocationProblemDelegate: class {
    func retry()
}

class LocationProblemViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var gifView: LoopingVideoView!
    @IBOutlet private var explanationLabel: BodyTextLabel!
    @IBOutlet private var primaryButton: UIButton!
    
    weak var delegate: LocationProblemDelegate?
    
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
        self.explanationLabel.tapDelegate = self
        self.explanationLabel.setLinkableText(problem.linkableCopy)
        
        if let image = problem.image {
            self.imageView.isHidden = false
            self.gifView.isHidden = true
            self.imageView.image = image
        } else if let url = problem.videoURL {
            self.imageView.isHidden = true
            self.gifView.isHidden = false
            self.gifView.videoURL = url
            self.gifView.play()
        } else {
            self.imageView.isHidden = true
            self.gifView.isHidden = true
        }
        
        if let buttonTitle = problem.primaryButtonTitle {
            self.primaryButton.isHidden = false
            self.primaryButton.setTitle(buttonTitle, for: .normal)
        } else {
            self.primaryButton.isHidden = true
        }
    }
    
    @IBAction private func primaryButtonTapped() {
        guard let problem = self.locationProblem else {
            ApplicationErrors.assertAndLog("You should have a problem by this point!")
            return
        }
        
        switch problem {
        case .notDetermined:
            LocationController.shared.requestAuthorization()
        case .disabledInSettings,
             .deniedByUser:
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                fatalError("Could not construct settings URL!")
            }
            UIApplication.shared.open(settingsURL)
        case .authorizedButWrongCountry:
            // Re-check the user's location
            delegate?.retry()
        case .restrictedByParentalControls:
            ApplicationErrors.assertAndLog("You shouldn't be able to get here, this button should be gone!")
        }
    }
    
    func listenForChanges() {
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
            self.listenForChanges()
        case .denied:
            self.locationProblem = .deniedByUser
            self.listenForChanges()
        case .notDetermined:
            self.locationProblem = .notDetermined
            self.listenForChanges()
        case .authorizedAlways,
             .authorizedWhenInUse:
            self.delegate?.retry()
        @unknown default:
            ApplicationErrors.assertAndLog("Apple added a new status here! You should update this handling.")
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

extension LocationProblemViewController: LabelTapDelegate {
    
    func tappedAttributedLabel(_ label: UILabel, at characterIndex: Int) {
        guard self.locationProblem!.linkableCopy.isIndexLinked(characterIndex) else {
            return
        }
        
        UIApplication.shared.open(ExternalLink.locationRequirement.url)
    }
}
