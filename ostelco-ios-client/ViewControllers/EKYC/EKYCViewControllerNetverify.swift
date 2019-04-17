//
//  EKYCViewControllerNetverify.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Netverify

extension EKYCViewController: NetverifyViewControllerDelegate {

  func getnewScanId(_ completion: @escaping (String?, Error?) -> Void) {
    // This method should fetch new scanId from our server
    completion(UUID().uuidString, nil)
  }

  func createNetverifyController() {
    // Prevent SDK to be initialized on Jailbroken devices
    if JMDeviceInfo.isJailbrokenDevice() {
      print("Will not allow this from a jailbroken device")
      return
    }
    var message = "JumioToken: \(Environment().configuration(.JumioToken)) \n"
    message += "JumioSecret: \(Environment().configuration(.JumioSecret))"
    //self.showAlert(title: "Jumio Settings", msg: message)

    // Setup the Configuration for Netverify
    let config: NetverifyConfiguration = NetverifyConfiguration()
    config.merchantApiToken = Environment().configuration(.JumioToken) // Fill this from JUMIO console
    config.merchantApiSecret = Environment().configuration(.JumioSecret) //Fill this from JUMIO console
    config.merchantScanReference = self.merchantScanReference
    config.requireVerification = true
    config.requireFaceMatch = true
    config.delegate = self

    // General appearance - deactivate blur
    NetverifyBaseView.netverifyAppearance().disableBlur = true
    // General appearance - background color
    NetverifyBaseView.netverifyAppearance().backgroundColor =
      UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1)
    // Positive Button - Background Color
    NetverifyPositiveButton.netverifyAppearance().setBackgroundColor(
      UIColor(red: 47 / 255.0, green: 22 / 255.0, blue: 232 / 255.0, alpha: 1),
      for: .normal
    )

    // Create the verification view
    self.netverifyViewController = NetverifyViewController(configuration: config)
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
      // For iPad, present from sheet
      self.netverifyViewController?.modalPresentationStyle = UIModalPresentationStyle.formSheet
    }
  }

  func startNetverify() {
    getnewScanId { (scanId, error) in
      if let scanId: String = scanId {
        print("Retrieved \(scanId)")
        self.merchantScanReference = scanId
        self.createNetverifyController()
        if let netverifyVC = self.netverifyViewController {
          self.present(netverifyVC, animated: true, completion: nil)
        } else {
          self.showAlert(title: "Netverify Mobile SDK", msg: "NetverifyViewController is nil")
        }
      } else if let error: Error = error {
        print("Failed to retrieve a new scan Id \(error)")
      }
    }
  }

  func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishWith documentData: NetverifyDocumentData, scanReference: String) {
    print("NetverifyViewController finished successfully with scan reference: %@", scanReference)
    let message = documentDataToString(documentData)
    self.dismiss(animated: true, completion: {
      print(message)
      self.showAlert(title: "Netverify Mobile SDK", msg: message as String)
      self.netverifyViewController?.destroy()
      self.netverifyViewController = nil
    })
  }

  func netverifyViewController(_ netverifyViewController: NetverifyViewController, didCancelWithError error: NetverifyError?, scanReference: String?) {
    print("NetverifyViewController cancelled with error: " + "\(error?.message ?? "")" + "scanReference: " + "\(scanReference ?? "")")
    
    // Dismiss the SDK
    self.dismiss(animated: true) {
      self.netverifyViewController?.destroy()
      self.netverifyViewController = nil
      let alert = UIAlertController(title: "Jumio failed", message: "somehow?", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.present(alert, animated: true)
      // self.performSegue(withIdentifier: "yourAddress", sender: self)
    }
  }
}
