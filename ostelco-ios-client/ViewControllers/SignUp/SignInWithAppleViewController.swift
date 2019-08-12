//
//  SignInWithAppleViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 09/08/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AuthenticationServices

protocol SignInWithAppleDelegate: class {
    func signedIn(authCode: String, contactEmail: String?)
}

class SignInWithAppleViewController: UIViewController {

    @IBOutlet weak private var buttonStackView: UIStackView!
    weak public var delegate: SignInWithAppleDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupProviderLoginView()
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.buttonStackView.addArrangedSubview(authorizationButton)
    }

    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SignInWithAppleViewController: StoryboardLoadable {

    static var storyboard: Storyboard {
        return .signInWithApple
    }

    static var isInitialViewController: Bool {
        return true
    }
}

extension SignInWithAppleViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let contactEmail = appleIDCredential.email
            debugPrint(userIdentifier, fullName ?? "No name", contactEmail ?? "No Email")
            if let data = appleIDCredential.identityToken {
                debugPrint(String(data: data, encoding: .utf8) ?? "No Identity Token")
            }
            if contactEmail == nil {
                debugPrint("Email not provided at Sign In, create user will fail.")
            }
            guard let authCodeData = appleIDCredential.authorizationCode else {
                print("No authorization code received at Sign In, cannot procced.")
                return
            }
            if let authCode = String(data: authCodeData, encoding: .utf8) {
                delegate?.signedIn(authCode: authCode, contactEmail: contactEmail)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension SignInWithAppleViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
