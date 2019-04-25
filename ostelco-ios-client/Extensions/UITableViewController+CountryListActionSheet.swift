//
//  UIViewController+CountryListActionSheet.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
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
        
        // Action sheet crashes on iPad: https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            if let popoverController = alertCtrl.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        present(alertCtrl, animated: true, completion: nil)
    }
}
