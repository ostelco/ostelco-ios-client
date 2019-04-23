//
//  LocationAccessRestrictedViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCoreLocation

class LocationAccessRestrictedViewController: UIViewController {
    let bag = DisposeBag()
    let manager = CLLocationManager()

    @IBOutlet private weak var descriptionLabel: UILabel!
    
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
                    assertionFailure("Apple added something new here! You should update your handling.")
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
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
}
