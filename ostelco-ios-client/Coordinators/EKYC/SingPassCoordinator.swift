//
//  SingPassCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import SafariServices
import UIKit

protocol SingPassCoordinatorDelegate: class {
    func signInSucceeded(myInfoQueryItems: [URLQueryItem])
    func signInFailed(error: NSError?)
}

class SingPassCoordinator: NSObject {
 
    weak var delegate: SingPassCoordinatorDelegate?
    
    func startLogin(from viewController: UIViewController) {
        
        UIApplication.shared.typedDelegate.myInfoDelegate = self
        let spinnerView = viewController.showSpinner(onView: viewController.view)
        // Fetch the configuration from prime
        APIManager.shared.primeAPI
            .loadMyInfoConfig()
            .ensure { [weak viewController] in
                viewController?.removeSpinner(spinnerView)
            }
            .done { [weak self] myInfoConfig in
                debugPrint("MyInfoConfig.url: \(myInfoConfig.url)")
                var components = URLComponents(string: myInfoConfig.url)!
                // Add mandatory purpose and state parameters to the MyInfo authorization url.
                // The "purpose" parameter contains the string which is shown to the user when
                // requesting the consent.
                // The "state" is an identifer used to reconcile query and response. This is
                // currently ignored by prime.
                // https://www.ndi-api.gov.sg/library/trusted-data/myinfo/tutorial2
                var queryItems: [URLQueryItem] = components.queryItems ?? []
                let extraQueryItems: [URLQueryItem] = [
                    URLQueryItem(name: "purpose", value: "eKYC"),
                    URLQueryItem(name: "state", value: "123")
                ]
                queryItems.append(contentsOf: extraQueryItems)
                components.queryItems = queryItems
                // Show the login screen.
                self?.showMyInfoLogin(url: components.url, from: viewController)
            }
            .catch { [weak viewController] error in
                ApplicationErrors.log(error)
                viewController?.showGenericError(error: error)
            }
    }
    
    func showMyInfoLogin(url: URL?, from viewController: UIViewController) {
        guard let url = url else {
            let error = ApplicationErrors.General.noMyInfoConfigFound
            ApplicationErrors.assertAndLog(error)
            return
        }
        debugPrint("URL for the login screen: \(url.absoluteString)")
        let webView = SFSafariViewController(url: url)
        webView.delegate = self
        viewController.present(webView, animated: true)
    }
}

extension SingPassCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
}

extension SingPassCoordinator: MyInfoCallbackHandler {
    func handleCallback(queryItems: [URLQueryItem]?, error: NSError?) {
        if let queryItems = queryItems {
            self.delegate?.signInSucceeded(myInfoQueryItems: queryItems)
        } else {
            self.delegate?.signInFailed(error: error)
        }
    }
}
