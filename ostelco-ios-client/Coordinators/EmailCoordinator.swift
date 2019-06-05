//
//  EmailCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

protocol EmailCoordinatorDelegate: class {
    func emailSuccessfullyVerified()
}

class EmailCoordinator {
    enum Destination {
        case enterEmail
        case verifyEmail
        case emailVerified
    }
    
    weak var delegate: EmailCoordinatorDelegate?
    
    private let navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func determineDestination(emailEntered: Bool, emailVerified: Bool = false) -> EmailCoordinator.Destination {
        
        guard emailEntered else {
            return .enterEmail
        }
        
        guard emailVerified else {
            return .verifyEmail
        }
        
        return .emailVerified
    }
    
    func navigate(to destination: Destination, animated: Bool) {
        switch destination {
        case .enterEmail:
            let enterEmailVC = EmailEntryViewController.fromStoryboard()
           enterEmailVC.coordinator = self
            self.navigationController.setViewControllers([enterEmailVC], animated: animated)
        case .verifyEmail:
            let checkVC = CheckEmailViewController.fromStoryboard()
           checkVC.coordinator = self
            self.navigationController.setViewControllers([checkVC], animated: animated)
        case .emailVerified:
            self.delegate?.emailSuccessfullyVerified()
        }
    }
    
    func emailLinkSent() {
        let destination = self.determineDestination(emailEntered: true)
        self.navigate(to: destination, animated: true)
    }
    
    func emailVerified() {
        let destination = self.determineDestination(emailEntered: true, emailVerified: true)
        self.navigate(to: destination, animated: true)
    }
}
