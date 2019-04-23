//
//  LocationAccessDeniedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCoreLocation
import CoreLocation

class LocationAccessDeniedViewController: UIViewController {
    let bag = DisposeBag()
    let manager = CLLocationManager()

    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBAction private func settingsTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "We need to verify that you are in \(OnBoardingManager.sharedInstance.selectedCountry.name ?? "NO COUNTRY") in order to continue"
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
            .subscribe(onNext: {_ in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwind", sender: self)
                }
            })
            .disposed(by: bag)
    }
}
