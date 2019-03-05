//
//  SingPassView.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SingPassView: IdentityView {
  @IBAction func continueSingPass(_ sender: Any) {
    delegate.tappedContinue(self)
  }
}
