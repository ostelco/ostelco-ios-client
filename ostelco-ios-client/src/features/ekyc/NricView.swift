//
//  NricView.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class NricView: IdentityView {
  @IBAction func continueNric(_ sender: Any) {
    delegate.tappedContinue(self)
  }
}
