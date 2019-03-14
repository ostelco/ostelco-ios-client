//
//  FLApplication.swift
//  ostelco-ios-client
//
//  Created by mac on 3/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase


class FLApplication: UIApplication
{
    override func sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        if let button = sender as? UIButton {
            Analytics.logEvent("button_tapped", parameters: ["newValue": button.title(for: .normal)!])
        }
        print("\nHold up, \(type(of: self)) again! Attempting to send \(action) to \(target) from sender \(sender.self)")
        
        return super.sendAction(action, to: target, from: sender, for: event)
    }
    
    /*
    override func sendEvent(_ event: UIEvent) {
        if let phase = event.allTouches?.first?.phase {
            print("\nHello from \(type(of: self)), the principal UIApplication class! Dispatched \"\(phase)\" event!")
        }
        
        super.sendEvent(event)
    }
    */
    
    /*
     override func nextResponder() -> UIResponder? {
     let nextResponder = super.nextResponder()
     printNextResponder(nextResponder)
     
     return nextResponder
     }
     */
}
