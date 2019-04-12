//
//  NRCIVerifyViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Netverify
import Crashlytics

class NRCIVerifyViewController: UIViewController {
    var spinnerView: UIView?
    var netverifyViewController:NetverifyViewController?
    var merchantScanReference:String = ""
    @IBOutlet weak var nricTextField: UITextField!
    @IBOutlet weak var nricErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }

    @IBAction func continueTapped(_ sender: Any) {
        // TODO: API fails with 500 so we start netverify regardless of failure / success until API is fixed
        if let nric = nricTextField.text, !nric.isEmpty {
            let countryCode = OnBoardingManager.sharedInstance.selectedCountry.countryCode.lowercased()
            nricErrorLabel.isHidden = true
            spinnerView = showSpinner(onView: self.view)
            APIManager.sharedInstance.regions.child(countryCode).child("/kyc/dave").child(nric).load()
                .onSuccess { entity in
                    self.startNetverify()
                }
                .onFailure { requestError in
                    do {
                        let jsonRequestError = try JSONDecoder().decode(JSONRequestError.self, from: requestError.entity!.content as! Data)
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
        let config:NetverifyConfiguration = NetverifyConfiguration()
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
            UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        // Positive Button - Background Color
        NetverifyPositiveButton.netverifyAppearance().setBackgroundColor(
            UIColor(red: 47/255.0, green: 22/255.0, blue: 232/255.0, alpha: 1),
            for: .normal
        )

        // Create the verification view
        self.netverifyViewController = NetverifyViewController(configuration: config)
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            // For iPad, present from sheet
            self.netverifyViewController?.modalPresentationStyle = UIModalPresentationStyle.formSheet;
        }
    }

    func startNetverify() -> Void {
        //self.performSegue(withIdentifier: "yourAddress", sender: self)
        getnewScanId() { (scanId, error) in
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
        print("NetverifyViewController finished successfully with scan reference: %@", scanReference);
        let message = documentDataToString(documentData)
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

    func documentDataToString(_ documentData: NetverifyDocumentData) -> String {
        let selectedCountry:String = documentData.selectedCountry
        let selectedDocumentType:NetverifyDocumentType = documentData.selectedDocumentType
        var documentTypeStr:String
        switch (selectedDocumentType) {
        case .driverLicense:
            documentTypeStr = "DL"
            break;
        case .identityCard:
            documentTypeStr = "ID"
            break;
        case .passport:
            documentTypeStr = "PP"
            break;
        case .visa:
            documentTypeStr = "Visa"
            break;
        default:
            documentTypeStr = ""
            break;
        }

        //id
        let idNumber:String? = documentData.idNumber
        let personalNumber:String? = documentData.personalNumber
        let issuingDate:Date? = documentData.issuingDate
        let expiryDate:Date? = documentData.expiryDate
        let issuingCountry:String? = documentData.issuingCountry
        let optionalData1:String? = documentData.optionalData1
        let optionalData2:String? = documentData.optionalData2

        //person
        let lastName:String? = documentData.lastName
        let firstName:String? = documentData.firstName
        let dateOfBirth:Date? = documentData.dob
        let gender:NetverifyGender = documentData.gender
        var genderStr:String;
        switch (gender) {
        case .unknown:
            genderStr = "Unknown"
        case .F:
            genderStr = "female"
        case .M:
            genderStr = "male"
        case .X:
            genderStr = "Unspecified"
        default:
            genderStr = "Unknown"
        }

        let originatingCountry:String? = documentData.originatingCountry

        //address
        let street:String? = documentData.addressLine
        let city:String? = documentData.city
        let state:String? = documentData.subdivision
        let postalCode:String? = documentData.postCode

        // Raw MRZ data
        let mrzData:NetverifyMrzData? = documentData.mrzData

        let message:NSMutableString = NSMutableString.init()
        message.appendFormat("Selected Country: %@", selectedCountry)
        message.appendFormat("\nDocument Type: %@", documentTypeStr)
        if (idNumber != nil) { message.appendFormat("\nID Number: %@", idNumber!) }
        if (personalNumber != nil) { message.appendFormat("\nPersonal Number: %@", personalNumber!) }
        if (issuingDate != nil) { message.appendFormat("\nIssuing Date: %@", issuingDate! as CVarArg) }
        if (expiryDate != nil) { message.appendFormat("\nExpiry Date: %@", expiryDate! as CVarArg) }
        if (issuingCountry != nil) { message.appendFormat("\nIssuing Country: %@", issuingCountry!) }
        if (optionalData1 != nil) { message.appendFormat("\nOptional Data 1: %@", optionalData1!) }
        if (optionalData2 != nil) { message.appendFormat("\nOptional Data 2: %@", optionalData2!) }
        if (lastName != nil) { message.appendFormat("\nLast Name: %@", lastName!) }
        if (firstName != nil) { message.appendFormat("\nFirst Name: %@", firstName!) }
        if (dateOfBirth != nil) { message.appendFormat("\ndob: %@", dateOfBirth! as CVarArg) }
        message.appendFormat("\nGender: %@", genderStr)
        if (originatingCountry != nil) { message.appendFormat("\nOriginating Country: %@", originatingCountry!) }
        if (street != nil) { message.appendFormat("\nStreet: %@", street!) }
        if (city != nil) { message.appendFormat("\nCity: %@", city!) }
        if (state != nil) { message.appendFormat("\nState: %@", state!) }
        if (postalCode != nil) { message.appendFormat("\nPostal Code: %@", postalCode!) }
        if (mrzData != nil) {
            if (mrzData?.line1 != nil) {
                message.appendFormat("\nMRZ Data: %@\n", (mrzData?.line1)!)
            }
            if (mrzData?.line2 != nil) {
                message.appendFormat("%@\n", (mrzData?.line2)!)
            }
            if (mrzData?.line3 != nil) {
                message.appendFormat("%@\n", (mrzData?.line3)!)
            }
        }
        return message as String
    }
}
