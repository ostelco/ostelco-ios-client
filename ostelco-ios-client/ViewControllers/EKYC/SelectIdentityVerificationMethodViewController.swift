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
    var spinnerView: UIView?

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
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "singpass"))
            //performSegue(withIdentifier: "myInfoSummary", sender: self)
            UIApplication.shared.typedDelegate.myInfoDelegate = self
            startMyInfoLogin()
        } else if self.scanICCheck.isChecked {
            OstelcoAnalytics.logEvent(.ChosenIDMethod(idMethod: "jumio"))
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
    
    func startMyInfoLogin() {
        self.spinnerView = self.showSpinner(onView: self.view)
        // Fetch the configuration from prime
        APIManager.shared.primeAPI
            .loadMyInfoConfig()
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] myInfoConfig in
                debugPrint("MyInfoConfig.url: \(myInfoConfig.url)")
                var components = URLComponents(string: myInfoConfig.url)!
                // Add purpose and state parameters to the url.
                // state parameter is currently ignored by prime.
                components.queryItems = [
                    URLQueryItem(name: "purpose", value: "eKYC"),
                    URLQueryItem(name: "state", value: "123")
                ]
                // Show the login screen.
                self?.showMyInfoLogin(url: components.url)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }

    }
    
    func showMyInfoLogin(url: URL?) {
        if let url = url {
            debugPrint("URL for the login screen: \(url.absoluteString)")
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

extension SelectIdentityVerificationMethodViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
