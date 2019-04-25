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
    
    var spinnerView: UIView?
    var userLocation: CLLocation?
    
    var locationManager = CLLocationManager()
    
    var descriptionText: String = ""
    
    // This is set in viewDidLoad
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var selectedCountry: Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
        self.descriptionLabel.text = "We need to verify that you are in \(self.selectedCountry.name ?? "(Unknown)") in order to continue"
        self.locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.verifyLocation(ignoreNotDetermined: true)
    }
    
    private func showFailedToGetLocationAlert() {
        let alert = UIAlertController(title: "We're sorry but...", message: "We were unable to get your current location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        self.verifyLocation()
    }
    
    private func showLocationProblemViewController(for problem: LocationProblem) {
        let problemVC = LocationProblemViewController.fromStoryboard()
        problemVC.locationProblem = problem
        self.present(problemVC, animated: true)
    }
    
    private func verifyLocation(ignoreNotDetermined: Bool = false) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                if !ignoreNotDetermined {
                    self.locationManager.requestAlwaysAuthorization()
                } else {
                    self.showLocationProblemViewController(for: .notDetermined)
                }
            case .restricted:
                self.showLocationProblemViewController(for: .restrictedByParentalControls)
            case .denied:
                self.showLocationProblemViewController(for: .deniedByUser)
            case .authorizedAlways,
                 .authorizedWhenInUse:
                userLocation = nil
                // TODO: Spinner is added twice for some reason in some cases
                if spinnerView == nil {
                    spinnerView = showSpinner(onView: view, loadingText: "Checking location...")
                }
                locationManager.requestLocation()
            @unknown default:
                assertionFailure("Apple added another case to this! You should update your handling.")
            }
        } else {
            self.showLocationProblemViewController(for: .disabledInSettings)
        }
    }
}

extension AllowLocationAccessViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.userLocation == nil else {
            // We've already got a user location, we're good here.
            return
        }
        
        self.removeSpinner(spinnerView)
        self.spinnerView = nil
        guard let location = locations.first else {
            // We haven't gotten any locations yet.
            return
        }
        
        debugPrint("Location: \(location)")
        self.userLocation = location
        CLGeocoder().reverseGeocode(location: location)
            .done { [weak self] placemarks in
                guard let self = self else {
                    // None of this matters
                    return
                }
                
                guard
                    let placemark = placemarks.first,
                    let country = placemark.country,
                    let isoCountryCode = placemark.isoCountryCode else {
                        debugPrint("Could not get matching address from placemark!")
                        self.showFailedToGetLocationAlert()
                        return
                }
                
                if self.selectedCountry?.countryCode == isoCountryCode {
                    // Hooray, this is the correct location!
                    self.performSegue(withIdentifier: "showEKYC", sender: self)
                } else {
                    // We're in the wrong country!
                    self.showLocationProblemViewController(for: .authorizedButWrongCountry(expected: self.selectedCountry.name ?? "(Unknown)", actual: country))
                }
            }
            .catch { [weak self] error in
                debugPrint("Unable to reverse geocode location. Error: \(error)")
                self?.showFailedToGetLocationAlert()
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.removeSpinner(self.spinnerView)
        self.spinnerView = nil
        debugPrint("Failed to find user's location: \(error.localizedDescription)")
        self.showFailedToGetLocationAlert()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.verifyLocation(ignoreNotDetermined: true)
    }
}
