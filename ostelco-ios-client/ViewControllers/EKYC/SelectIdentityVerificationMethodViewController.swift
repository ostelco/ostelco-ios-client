//
//  SelectIdentityVerificationMethodViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SafariServices
import OstelcoStyles

class SelectIdentityVerificationMethodViewController: UIViewController {
    
    @IBOutlet private var singPassCheck: CheckButton!
    @IBOutlet private var scanICCheck: CheckButton!
    @IBOutlet private var continueButton: UIButton!
    
    var webView: SFSafariViewController?
    var myInfoQueryItems: [URLQueryItem]?
    
    @IBAction private func checkTapped(_ check: CheckButton) {
        check.isChecked.toggle()
        
        switch check {
        case self.singPassCheck:
            self.scanICCheck.isChecked = false
        case self.scanICCheck:
            self.singPassCheck.isChecked = false
        default:
            assertionFailure("Unknown option toggled!")
        }
        
        self.updateContinue()
    }
    
    @IBAction private func continueTapped() {
        if self.singPassCheck.isChecked {
            //performSegue(withIdentifier: "myInfoSummary", sender: self)
            UIApplication.shared.typedDelegate.myInfoDelegate = self
            getMyInfoToken()
        } else if self.scanICCheck.isChecked {
            performSegue(withIdentifier: "nricVerify", sender: self)
        } else {
            assertionFailure("At least one of these should be checked if continue is enabled!")
        }
    }
    
    private func updateContinue() {
        if self.singPassCheck.isChecked || self.scanICCheck.isChecked {
            self.continueButton.isEnabled = true
        } else {
            self.continueButton.isEnabled = false
        }
    }
    
    @IBAction private func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    func getMyInfoURL() -> URL? {
        var components = URLComponents(string: Environment().configuration(PlistKey.MyInfoURL))!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Environment().configuration(PlistKey.MyInfoClientID)),
            //TODO: Find the right values for the query parameters.
            //URLQueryItem(name: "attributes", value: "name,nationality,dob,email,mobileno,regadd"),
            URLQueryItem(name: "attributes", value: "name,sex,race,nationality,dob,email,mobileno,regadd,housingtype,hdbtype,marital,edulevel,assessableincome,ownerprivate,assessyear,cpfcontributions,cpfbalances"),
            URLQueryItem(name: "purpose", value: "eKYC"),
            URLQueryItem(name: "state", value: "123"),
            URLQueryItem(name: "redirect_uri", value: Environment().configuration(PlistKey.MyInfoCallbackURL)),
        ]
        return components.url
    }
    
    func getMyInfoToken() {
        if let url = getMyInfoURL() {
            print("URL for API \(url.absoluteString)")
            webView = SFSafariViewController(url: url)
            webView!.delegate = self
            present(webView!, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "myInfoSummary",
            let destinationVC = segue.destination as? MyInfoSummaryViewController {
            destinationVC.myInfoQueryItems = myInfoQueryItems
        }
    }
}

extension SelectIdentityVerificationMethodViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
        webView = nil
    }
}

extension SelectIdentityVerificationMethodViewController: MyInfoCallbackHandler {
    func handleCallback(queryItems: [URLQueryItem]?, error: NSError?) {
        dismiss(animated: false) { [weak self] in
            // Show the information gathered from MyInfo
            self?.myInfoQueryItems = queryItems
            self?.performSegue(withIdentifier: "myInfoSummary", sender: self)
        }
        webView = nil
    }
}
