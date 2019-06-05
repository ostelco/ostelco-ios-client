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
        case success
        case setupComplete
    }
    
    weak var delegate: ESimCoordinatorDelegate?
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func determineDestination(from simProfile: SimProfile?) -> ESimCoordinator.Destination {
        guard let profile = simProfile else {
            return .setup
        }
        
        switch profile.status {
        case .DOWNLOADED,
             .INSTALLED,
             .ENABLED:
            return .success
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
            onboarding.coordinator = self
            self.navigationController.setViewControllers([onboarding], animated: animated)
        case .instructions:
            let instructions = ESIMInstructionsViewController.fromStoryboard()
            instructions.coordinator = self
            self.navigationController.setViewControllers([instructions], animated: animated)
        case .pendingDownload:
            let pendingDownload = ESIMPendingDownloadViewController.fromStoryboard()
            pendingDownload.coordinator = self
            self.navigationController.setViewControllers([pendingDownload], animated: animated)
        case .success:
            let successVC = SignUpCompletedViewController.fromStoryboard()
            successVC.coordinator = self
            self.navigationController.setViewControllers([successVC], animated: animated)
        case .setupComplete:
            self.delegate?.esimSetupComplete()
        }
    }
    
    func completedLanding() {
        self.navigate(to: .instructions, animated: true)
    }
    
    func completedInstructions() {
        self.navigate(to: .pendingDownload, animated: true)
    }
    
    func acknowledgedSuccess() {
        self.navigate(to: .setupComplete, animated: true)
    }
}
