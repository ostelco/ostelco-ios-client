//
//  ESimCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

protocol ESimCoordinatorDelegate: class {
    func esimSetupComplete()
}

class ESimCoordinator {
    
    enum Destination {
        case setup
        case instructions
        case pendingDownload
        case success(profile: SimProfile)
        case setupComplete
    }
    
    weak var delegate: ESimCoordinatorDelegate?
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func determineDestination(from simProfile: SimProfile?,
                              hasSeenSetup: Bool = false,
                              hasSeenInstructions: Bool = false,
                              hasAcknowledgedSuccess: Bool = false) -> ESimCoordinator.Destination {
        guard let profile = simProfile else {
            if hasSeenSetup && hasSeenInstructions {
                return .pendingDownload
            } else if hasSeenSetup {
                return .instructions
            } else {
                return .setup
            }
        }
        
        switch profile.status {
        case .DOWNLOADED,
             .INSTALLED,
             .ENABLED:
            if hasAcknowledgedSuccess {
                return .setupComplete
            } else {
                return .success(profile: profile)
            }
        case .AVAILABLE_FOR_DOWNLOAD,
             .NOT_READY:
            // TODO: Figure out if .NOT_READY should show an error instead
            return .pendingDownload
        }
    }
    
    func navigate(to destination: ESimCoordinator.Destination, animated: Bool) {
        switch destination {
        case .setup:
            let onboarding = ESIMOnBoardingViewController.fromStoryboard()
            onboarding.delegate = self
            self.navigationController.setViewControllers([onboarding], animated: animated)
        case .instructions:
            let instructions = ESIMInstructionsViewController.fromStoryboard()
            instructions.delegate = self
            self.navigationController.setViewControllers([instructions], animated: animated)
        case .pendingDownload:
            let pendingDownload = ESIMPendingDownloadViewController.fromStoryboard()
            pendingDownload.delegate = self
            self.navigationController.setViewControllers([pendingDownload], animated: animated)
        case .success(let profile):
            let successVC = SignUpCompletedViewController.fromStoryboard()
            successVC.profile = profile
            successVC.delegate = self
            self.navigationController.setViewControllers([successVC], animated: animated)
        case .setupComplete:
            self.delegate?.esimSetupComplete()
        }
    }
}

extension ESimCoordinator: ESIMOnBoardingDelegate {
    func completedLanding() {
        let destination = self.determineDestination(from: nil, hasSeenSetup: true)
        self.navigate(to: destination, animated: true)
    }
}

extension ESimCoordinator: ESIMInstructionsDelegate {
    func completedInstructions() {
        let destination = self.determineDestination(from: nil, hasSeenSetup: true, hasSeenInstructions: true)
        self.navigate(to: destination, animated: true)
    }
}

extension ESimCoordinator: ESIMPendingDownloadDelegate {
    func profileChanged(_ profile: SimProfile) {
        let destination = self.determineDestination(from: profile)
        self.navigate(to: destination, animated: true)
    }
}

extension ESimCoordinator: SignUpCompletedDelegate {
    func acknowledgedSuccess(profile: SimProfile) {
        let destination = self.determineDestination(
            from: profile,
            hasSeenSetup: true,
            hasSeenInstructions: true,
            hasAcknowledgedSuccess: true
        )
        self.navigate(to: destination, animated: true)
    }
}
