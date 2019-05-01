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
        // TODO: API fails with 500 so we start netverify regardless of failure / success until API is fixed
        if let nric = nricTextField.text, !nric.isEmpty {
            let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
            nricErrorLabel.isHidden = true
            spinnerView = showSpinner(onView: self.view)
            APIManager.sharedInstance.regions.child(countryCode).child("/kyc/dave").child(nric).load()
                .onSuccess { _ in
                    self.startNetverify()
                }
                .onFailure { requestError in
                    do {
                        guard let errorData = requestError.entity?.content as? Data else {
                            throw APIHelper.Error.errorCameWithoutData
                        }
                        
                        let jsonRequestError = try JSONDecoder().decode(JSONRequestError.self, from: errorData)
                        switch jsonRequestError.errorCode {
                        case "INVALID_NRIC_FIN_ID":
                            self.nricErrorLabel.isHidden = false
                        default:
                            Crashlytics.sharedInstance().recordError(requestError)
                            self.showAPIError(error: requestError)
                        }
                    } catch let error {
                        print(error)
                        Crashlytics.sharedInstance().recordError(error)
                        self.showAlert(title: "Error", msg: "Please try again later.")
                    }
                }
                .onCompletion { _ in
                    self.removeSpinner(self.spinnerView)
            }
        } else {
            showAlert(title: "Error", msg: "NRIC field can't be empty")
        }
    }
}

extension NRCIVerifyViewController: NetverifyViewControllerDelegate {
    
    func getnewScanId(_ completion: @escaping (String?, Error?) -> Void) {
        // This method should fetch new scanId from our server
        let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
        APIManager.sharedInstance.regions.child(countryCode).child("/kyc/jumio/scans")
            .request(.post, json: [])
            .onSuccess { data in
                if let scan: Scan = data.typedContent(ifNone: nil) {
                    completion(scan.scanId, nil)
                } else {
                    // TODO: Create more descriptive error. Not sure if this cause ever will happen, but that doesn't mean we shouldn't handle it somehow.
                    completion(nil, NSError(domain: "", code: 0, userInfo: nil))
                }
            }
            .onFailure { error in
                self.showAPIError(error: error)
                if let cause = error.cause {
                    completion(nil, cause)
                } else {
                    // TODO: Create more descriptive error. Not sure if this cause ever will happen, but that doesn't mean we shouldn't handle it somehow.
                    completion(nil, NSError(domain: "", code: error.httpStatusCode ?? 0, userInfo: nil))
                }
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
