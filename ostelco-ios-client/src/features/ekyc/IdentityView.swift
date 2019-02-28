//
//  IdentityView.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class IdentityView: UIView {
  weak var delegate: IdentityViewDelegate!
}

protocol IdentityViewDelegate: AnyObject {
  func tappedContinue(_ sender: IdentityView)
}
