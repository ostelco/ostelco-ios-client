
//
//  WrongCountryViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class WrongCountryViewController: UIViewController, WithCountryFieldProtocol {
    var country: String = ""
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = "It seems like you are not in \(country)"
    }
}
