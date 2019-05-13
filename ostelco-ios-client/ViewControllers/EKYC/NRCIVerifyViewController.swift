//
//  NRCIVerifyViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Crashlytics
import Netverify
import ostelco_core
import PromiseKit
import UIKit

class NRCIVerifyViewController: UIViewController {
    
    var spinnerView: UIView?
    var netverifyViewController: NetverifyViewController?
    var merchantScanReference: String = ""
    @IBOutlet private weak var nricTextField: UITextField!
    @IBOutlet private weak var nricErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction private func continueTapped(_ sender: Any) {
        guard
            let nric = self.nricTextField.text,
            nric.isNotEmpty else {
                self.showAlert(title: "Error", msg: "NRIC field can't be empty")
                return
        }
        
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        self.nricErrorLabel.isHidden = true
        self.spinnerView = self.showSpinner(onView: self.view)
        APIManager.shared.primeAPI
            .validateNRIC(nric, forRegion: countryCode)
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
            }
            .done { [weak self] isValid in
                if isValid {
                    self?.startNetverify()
                } else {
                    self?.nricErrorLabel.isHidden = false
                }
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }
}

extension NRCIVerifyViewController: NetverifyViewControllerDelegate {
    
    func getNewScanId() -> Promise<String> {
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        return APIManager.shared.primeAPI.createJumioScanForRegion(code: countryCode)
            .map { scan in
                return scan.scanId
            }
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
        // TODO: Replace preselected country with previously selected country when supporting multiple countries. Note that Preselected country below has to be on the following format https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
        // while we use alpha-2
        config.preselectedCountry = "SGP"
        
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
        self.getNewScanId()
            .done { [weak self] scanId in
                print("Retrieved \(scanId)")
                guard let self = self else {
                    // This got dealloc'd, bail out!
                    return
                }
                
                self.merchantScanReference = scanId
                self.createNetverifyController()
                if let netverifyVC = self.netverifyViewController {
                    self.present(netverifyVC, animated: true, completion: nil)
                } else {
                    self.showAlert(title: "Netverify Mobile SDK", msg: "NetverifyViewController is nil")
                }
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                print("Failed to retrieve a new scan Id \(error)")
                guard let self = self else {
                    // None of the rest of htis matters
                    return
                }
                
                self.showGenericError(error: error)
            }
    }
    
    func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishWith documentData: NetverifyDocumentData, scanReference: String) {
        debugPrint("NetverifyViewController finished successfully with scan reference: \(scanReference)")
        let message = documentData.toOstelcoString()
        self.dismiss(animated: true, completion: {
            print(message)
            // self.showAlert(title: "Netverify Mobile SDK", msg: message as String)
            self.netverifyViewController?.destroy()
            self.netverifyViewController = nil
            self.performSegue(withIdentifier: "yourAddress", sender: self)
        })
    }
    
    func netverifyViewController(_ netverifyViewController: NetverifyViewController, didCancelWithError error: NetverifyError?, scanReference: String?) {
        print("NetverifyViewController cancelled with error: " + "\(error?.message ?? "")" + "scanReference: " + "\(scanReference ?? "")")
        // Dismiss the SDK
        self.dismiss(animated: true) {
            self.netverifyViewController?.destroy()
            self.netverifyViewController = nil
            let alert = UIAlertController(title: "Info", message: "\(error?.message ?? "An unknown error occurred.")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
