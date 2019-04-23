//
//  FLApplication.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

class FLApplication: UIApplication {
    override func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        if let button = sender as? UIButton {
            if let title = button.title(for: .normal) {
                Analytics.logEvent("button_tapped", parameters: ["newValue": title])
            } else {
                Analytics.logEvent("button_tapped", parameters: ["newValue": button.accessibilityLabel ?? "button has no text"])
            }
        }
        print("\nHold up, \(type(of: self)) again! Attempting to send \(action) to \(String(describing: target)) from sender \(String(describing: sender.self))")
        
        return super.sendAction(action, to: target, from: sender, for: event)
    }
}
