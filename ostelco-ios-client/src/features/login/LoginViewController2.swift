//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Firebase

// TODO: Remove "2" when deleting existing LoginViewController
class LoginViewController2: UIViewController {

    @IBAction func signInTapped(_ sender: UIButton) {
        // Trigger custom events to record button clicks
        Analytics.logEvent("button_tapped", parameters: ["newValue": sender.title(for: .normal)!])
        sharedAuth.loginWithAuth0().subscribe(
            onNext: { _ in

                // TODO: Duplicated logic from SplashViewController
                DispatchQueue.main.async {
                    self.showSpinner(onView: self.view)
                    APIManager.sharedInstance.context.load()
                        .onSuccess({ data in
                            if let context: Context = data.typedContent(ifNone: nil) {
                                DispatchQueue.main.async {
                                    UserManager.sharedInstance.user = context.customer
                                }
                                if let region = context.getRegion() {
                                    DispatchQueue.main.async {
                                        OnBoardingManager.sharedInstance.region = region
                                    }
                                    switch region.status {
                                    case .PENDING:
                                        if let jumio = region.kycStatusMap.JUMIO, let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER, let nricFin = region.kycStatusMap.NRIC_FIN {
                                            switch (jumio, addressAndPhoneNumber, nricFin) {
                                            case (.APPROVED, .APPROVED, .APPROVED):
                                                DispatchQueue.main.async {
                                                    self.perform(#selector(self.showEKYCLastScreen), with: nil, afterDelay: 0.5)
                                                }
                                            case (.REJECTED, _, _):
                                                DispatchQueue.main.async {
                                                    self.perform(#selector(self.showEKYCOhNo), with: nil, afterDelay: 0.5)
                                                }
                                            case (.PENDING, .APPROVED, .APPROVED):
                                                DispatchQueue.main.async {
                                                    self.perform(#selector(self.showESim), with: nil, afterDelay: 0.5)
                                                }
                                            default:
                                                DispatchQueue.main.async {
                                                    self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
                                                }
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
                                            }
                                        }
                                    case .APPROVED:
                                        // TODO: Redirect based on sim profiles in region
                                        DispatchQueue.main.async {
                                            self.perform(#selector(self.showESim), with: nil, afterDelay: 0.5)
                                        }
                                    case .REJECTED:
                                        DispatchQueue.main.async {
                                            self.perform(#selector(self.showEKYCOhNo), with: nil, afterDelay: 0.5)
                                        }
                                    default:
                                        DispatchQueue.main.async {
                                            self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
                                    }
                                }
                            } else {
                                preconditionFailure("Failed to parse user context from server response.")
                            }
                        })
                        .onFailure({ error in
                            if let statusCode = error.httpStatusCode {
                                switch statusCode {
                                case 404:
                                    DispatchQueue.main.async {
                                        self.perform(#selector(self.showSignUp), with: nil, afterDelay: 0.5)
                                    }
                                default:
                                    preconditionFailure("Failed to fetch user context from server: \(error.userMessage)")
                                }
                            } else {
                                preconditionFailure("Failed to fetch user context from server: \(error.userMessage)")
                            }
                        })
                        .onCompletion({ _ in
                            self.removeSpinner()
                        })
                }
        },
            onError: { error in
                DispatchQueue.main.async {
                    self.handleLoginFailure(message: "\(error)")
                }
        })
    }

    @objc private func showCountry() {
        performSegue(withIdentifier: "showCountry", sender: self)
        //performSegue(withIdentifier: "showEKYC", sender: nil)
    }

    @objc private func showSignUp() {
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }

    @objc private func showEKYCLastScreen() {
        performSegue(withIdentifier: "showEKYCLastScreen", sender: nil)
    }

    @objc private func showEKYCOhNo() {
        performSegue(withIdentifier: "showEKYCOhNo", sender: nil)
    }

    @objc private func showESim() {
        performSegue(withIdentifier: "showESim", sender: nil)
        //performSegue(withIdentifier: "showEKYC", sender: nil)
    }

    private func handleLoginFailure(message: String) {
        let alert = UIAlertController(title: "Failed to login", message: "Please try again later.\nIf this problem persists, contact customer support.\n Error: \(message)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
