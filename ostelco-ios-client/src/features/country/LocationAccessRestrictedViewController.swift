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

class LocationAccessRestrictedViewController: UIViewController, WithCountryFieldProtocol {
    var country: String = ""
    let bag = DisposeBag()
    let manager = CLLocationManager()
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "We need to verify that you are in \(country) in order to continue"
        manager.rx
            .didChangeAuthorization
            .debug("didChangeAuthorization")
            .filter({_,status in
                switch status {
                case .restricted, .denied:
                    return false
                case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                    return true
                }
            })
            .subscribe(onNext: {_ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: bag)
    }
}
