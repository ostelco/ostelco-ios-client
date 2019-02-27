//
//  EKYCViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EKYCViewController: UIViewController {
  @IBOutlet var singPassView: SingPassView!
  @IBOutlet var singPassErrorView: UIView!
  @IBOutlet var nricView: NricView!
  @IBOutlet weak var placeHolderView: UIView!
  @IBOutlet weak var identitySegments: UISegmentedControl!

  override func viewDidLoad() {
    singPassView.delegate = self
    nricView.delegate = self
    addSubViews()
    switchedSegment(identitySegments)
  }

  func addSubViews() {
    view.addSubview(
      singPassView,
      constrainedTo: placeHolderView,
      widthAnchorView: placeHolderView,
      multiplier: 1
    )
    view.addSubview(
      singPassErrorView,
      constrainedTo: placeHolderView,
      widthAnchorView: placeHolderView,
      multiplier: 1
    )
    view.addSubview(
      nricView,
      constrainedTo: placeHolderView,
      widthAnchorView: placeHolderView,
      multiplier: 1
    )
  }

  @IBAction func switchedSegment(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      singPassView.isHidden = true
      singPassErrorView.isHidden = false
      nricView.isHidden = true
    } else {
      singPassView.isHidden = true
      singPassErrorView.isHidden = true
      nricView.isHidden = false
    }
  }
}

extension EKYCViewController: IdentityViewDelegate {
  func tappedContinue(_ sender: IdentityView) {
    switch sender {
    case singPassView:
      continueSingPass()
    case nricView:
      continueNric()
    default:
      print("Unknown sender")
    }
  }
  func continueNric() {
    print("Continue NRIC")
  }
  func continueSingPass() {
    print("Continue SingPass")
  }


}

extension UIView {
  func addSubview(
    _ subview: UIView,
    constrainedTo anchorsView: UIView,
    widthAnchorView: UIView? = nil,
    multiplier: CGFloat = 1
  ) {
    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [subview.centerXAnchor.constraint(equalTo: anchorsView.centerXAnchor),
       subview.centerYAnchor.constraint(equalTo: anchorsView.centerYAnchor),
       subview.widthAnchor.constraint(
        equalTo: (widthAnchorView ?? anchorsView).widthAnchor,
        multiplier: multiplier
        ),
      subview.heightAnchor.constraint(
        equalTo: anchorsView.heightAnchor,
        multiplier: multiplier
        )]
    )
  }
}
