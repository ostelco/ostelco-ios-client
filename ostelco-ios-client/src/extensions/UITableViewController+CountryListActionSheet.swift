//
//  UIViewController+CountryListActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UITableViewController {
    func showCountryListActionSheet(countries: [Country], completion: @escaping () -> Void) {
        let alertCtrl = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        for country in countries {
            let alertAction = UIAlertAction(title: country.name, style: .default, handler: {_ in
                OnBoardingManager.sharedInstance.selectedCountry = country
                completion()
            })
            alertCtrl.addAction(alertAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertCtrl.addAction(cancelAction)

        present(alertCtrl, animated: true, completion: nil)
    }
}
