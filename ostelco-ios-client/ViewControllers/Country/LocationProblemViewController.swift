//
//  LocationProblemViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCoreLocation
import ostelco_core
import UIKit

class LocationProblemViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var explanationLabel: UILabel!
    @IBOutlet private var primaryButton: UIButton!
    
    private let bag = DisposeBag()
    private let manager = CLLocationManager()
    
    var locationProblem: LocationProblem? {
        didSet {
            self.configureForCurrentProblem()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureForCurrentProblem()
        self.listenForChanges()
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
        case .notDetermined,
             .disabledInSettings,
             .deniedByUser:
            UIApplication.shared.openSettings()
        case .authorizedButWrongCountry:
            // TODO: Refetch user's location.
            break
        case .restrictedByParentalControls:
            assertionFailure("You shouldn't be able to get here, this button should be gone!")
        }
    }
    
    private func listenForChanges() {
        manager.rx
            .didChangeAuthorization
            .debug("didChangeAuthorization")
            .filter({ _, status in
                switch status {
                case .restricted,
                     .denied:
                    return false
                case .authorizedAlways,
                     .authorizedWhenInUse,
                     .notDetermined:
                    return true
                @unknown default:
                    assertionFailure("Apple added a new status here! You should update this handling.")
                    return false
                }
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {_ in
                self.performSegue(withIdentifier: "locationAccessAllowedAndConfirmed", sender: self)
            })
            .disposed(by: bag)
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
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
