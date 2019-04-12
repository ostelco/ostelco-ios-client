//
//  AllowLocationAccessViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/28/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreLocation

class AllowLocationAccessViewController: UIViewController {

    @IBOutlet weak var fakeModalNotificationImage: UIImageView!
    var spinnerView: UIView?
    var userLocation: CLLocation!

    var locationManager = CLLocationManager()

    var descriptionText: String = ""
    var selectedCountry: Country?

    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCountry = OnBoardingManager.sharedInstance.selectedCountry
        descriptionLabel.text = "We need to verify that you are in \(selectedCountry?.name ?? "NO COUNTRY") in order to continue"
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        verifyLocation(ignoreNotDetermined: true)
    }

    @IBAction func dontAllowTapped(_ sender: Any) {
        let alert = UIAlertController(title: "We're sorry but...", message: "You have to allow location access to be able to continue so that you can start using your free 2GB.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.verifyLocation()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func failedToGetLocationAlert() {
        let alert = UIAlertController(title: "We're sorry but...", message: "We were unable to get your current location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func okTapped(_ sender: Any) {
        verifyLocation()
    }

    @IBAction func continueTapped(_ sender: Any) {
        verifyLocation()
    }

    private func showLocationServiceDisabled() {
        performSegue(withIdentifier: "showLocationServiceDisabled", sender: self)
    }

    private func showLocationAccessDenied() {
        performSegue(withIdentifier: "showLocationAccessDenied", sender: self)
    }

    private func showLocationAccessRestricted() {
        performSegue(withIdentifier: "showLocationAccessRestricted", sender: self)
    }

    private func handleDenied() {
    }

    @IBAction func unwindToAllowLocationAccessViewController(segue: UIStoryboardSegue) {
        verifyLocation()
    }

    private func verifyLocation(ignoreNotDetermined: Bool = false) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()

            switch status {
            case .notDetermined:
                if !ignoreNotDetermined {
                    locationManager.requestAlwaysAuthorization()
                }
            case .restricted:
                showLocationAccessRestricted()
            case .denied:
                showLocationAccessDenied()
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
            showLocationServiceDisabled()
        }
    }

    private func showWrongCountry() {
        performSegue(withIdentifier: "showWrongCountry", sender: self)
    }
}

extension AllowLocationAccessViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if userLocation == nil {
            removeSpinner(spinnerView)
            spinnerView = nil
            if let location = locations.first {
                userLocation = location
                print("Location: \(location)")
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        print("Unable to Reverse Geocode Location (\(error))")
                        // locationLabel.text = "Unable to Find Address for Location"
                        self.failedToGetLocationAlert() 
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first, let country = placemark.country, let isoCountryCode = placemark.isoCountryCode {
                            print("country: \(country) isoCountryCode: \(isoCountryCode)")
                            if self.selectedCountry?.countryCode == isoCountryCode {
                                // Location verified
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "showEKYC", sender: self)
                                }
                            } else {
                                // Location not in correct country
                                DispatchQueue.main.async {
                                    // TODO: Fake country verification for MVP
                                    // self.showWrongCountry()
                                    self.performSegue(withIdentifier: "showEKYC", sender: self)
                                }
                            }
                        } else {
                            print("No Matching Addresses Found")
                            self.failedToGetLocationAlert()
                        }
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        removeSpinner(spinnerView)
        spinnerView = nil
        print("Failed to find user's location: \(error.localizedDescription)")
        failedToGetLocationAlert()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        verifyLocation(ignoreNotDetermined: true)
    }
}

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        if let p = source.presentingViewController {
            p.dismiss(animated: true, completion: nil)
        }
    }
}
