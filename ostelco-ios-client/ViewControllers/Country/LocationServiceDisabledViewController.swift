//
//  LocationServiceDisabledViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import CoreLocation
import RxCoreLocation
import RxSwift

class LocationServiceDisabledViewController: UIViewController {
    let bag = DisposeBag()
    let manager = CLLocationManager()

    @IBOutlet weak var descriptionLabel: UILabel!

    @IBAction func retryTapped(_ sender: Any) {
        self.checkLocationServiceStatus()
    }

    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "We need to verify that you are in \(OnBoardingManager.sharedInstance.selectedCountry.name ?? "NO COUNTRY") in order to continue"
    }

    private func checkLocationServiceStatus() {
        manager.rx
            .isEnabled
            .debug("isEnabled")
            .filter({ isEnabled in
                return isEnabled
            })
            .subscribe(onNext: {_ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: bag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            self.dismiss(animated: true)
        }
    }
}
