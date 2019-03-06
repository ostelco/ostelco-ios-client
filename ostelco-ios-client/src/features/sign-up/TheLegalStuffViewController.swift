//
//  TheLegalStuffViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class TheLegalStuffViewController: UIViewController {
    
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var oyaUpdatesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "I hereby agree to the Terms & Conditions", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0, weight: .bold), range: NSRange(location: 22, length: 18))
        termsAndConditionsLabel.attributedText = attributedString
        
        let attributedString2 = NSMutableAttributedString(string: "I agree to the  Privacy Policy", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0, weight: .bold), range: NSRange(location: 16, length: 14))
        privacyPolicyLabel.attributedText = attributedString2
        
        let attributedString3 = NSMutableAttributedString(string: "I agree to recieve OYA updates by email. This consent can be revoked at any time.", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        oyaUpdatesLabel.attributedText = attributedString3
        
    }
}
