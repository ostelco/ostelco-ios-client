//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit
import Firebase
import AuthenticationServices

protocol LoginDelegate: class {
    func signedIn(controller: UIViewController, authCode: String, contactEmail: String?)
    func signInError(controller: UIViewController, error: Error)
}

class LoginViewController: UIViewController {
    var spinnerView: UIView?
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private weak var buttonStackView: UIStackView!

    private var pageController: UIPageViewController!
    private var authorizationButton: ASAuthorizationAppleIDButton?

    weak var delegate: LoginDelegate?
    
    private lazy var dataSource: PageControllerDataSource = {
        let pages = OnboardingPage.allCases.map { $0.viewController }
        return PageControllerDataSource(
            pageController: pageController,
            viewControllers: pages,
            pageIndicatorTintColor: OstelcoColor.paginationInactive.toUIColor,
            currentPageIndicatorTintColor: OstelcoColor.paginationActive.toUIColor,
            delegate: self
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()

        let index = dataSource.currentIndex
        configureButtonTitle(for: index)
        logoImageView.tintColor = OstelcoColor.oyaBlue.toUIColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? UIPageViewController {
            self.pageController = pageController
        }
    }
    
    private func configureButtonTitle(for index: Int) {
        if index == (OnboardingPage.allCases.count - 1) {
            // This is the last page.
            authorizationButton!.cornerRadius = primaryButton.intrinsicContentSize.height / 2
            primaryButton.isHidden = true
            buttonStackView.isHidden = false // Show "Sign In With Apple"
            primaryButton.setTitle(NSLocalizedString("Sign In", comment: "Title for sign in button."), for: .normal) // Used for Analytics
        } else {
            primaryButton.setTitle(NSLocalizedString("Next", comment: "Action button in Carousel"), for: .normal)
            primaryButton.isHidden = false
            buttonStackView.isHidden = true
        }
    }

    func setupProviderLoginView() {
        authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        authorizationButton!.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        buttonStackView.addArrangedSubview(authorizationButton!)
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

    @IBAction private func primaryButtonTapped(_ sender: UIButton) {
        Analytics.logEvent("button_tapped", parameters: [
            "newValue": sender.title(for: .normal)!
        ])
        
        let index = dataSource.currentIndex
        if index != (OnboardingPage.allCases.count - 1) {
            dataSource.goToNextPage()
        }
    }
    
}

extension LoginViewController: PageControllerDataSourceDelegate {
 
    func pageChanged(to index: Int) {
        configureButtonTitle(for: index)
    }
}

extension LoginViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .login
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
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
                delegate?.signedIn(controller: self, authCode: authCode, contactEmail: contactEmail)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let authError = error as? ASAuthorizationError
        // If user has not canceled "Sign In With Apple", show error
        if authError == nil || authError?.code != .canceled {
            delegate?.signInError(controller: self, error: error)
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
