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
    func sendEmailLink(email: String)
}

class SignInWithAppleViewController: UIViewController {

    @IBOutlet weak var buttonStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupProviderLoginView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func setupProviderLoginView() {
         let authorizationButton = ASAuthorizationAppleIDButton()
         authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
         self.buttonStackView.addArrangedSubview(authorizationButton)
     }

    @objc
    func handleAuthorizationAppleIDButtonPress() {
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
