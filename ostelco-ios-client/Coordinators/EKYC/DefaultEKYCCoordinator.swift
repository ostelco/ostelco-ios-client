//
//  EKYCCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/3/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UIKit

class DefaultEKYCCoordinator: EKYCCoordinator {
    
    enum Destination {
        case goBackAndChooseCountry
        case landing
        case jumio
        case ekycRejected
        case success(region: RegionResponse)
        case waitingForVerification
    }
    
    let navigationController: UINavigationController
    let country: Country
    var jumioCoordinator: JumioCoordinator?
    weak var delegate: EKYCCoordinatorDelegate?
    
    init(navigationController: UINavigationController,
         country: Country) {
        self.navigationController = navigationController
        self.country = country
    }
    
    func determineDestination(from region: RegionResponse?,
                              hasSeenLanding: Bool = false) -> DefaultEKYCCoordinator.Destination {
        guard let region = region else {
            if hasSeenLanding {
                return .jumio
            } else {
                return .landing
            }
        }
        
        switch region.status {
        case .APPROVED:
            return .success(region: region)
        case .REJECTED:
            return .ekycRejected
        case .PENDING:
            guard let jumioStatus = region.kycStatusMap.JUMIO else {
                return .goBackAndChooseCountry
            }
            
            switch jumioStatus {
            case .APPROVED:
                return .success(region: region)
            case .REJECTED:
                return .ekycRejected
            case .PENDING:
                return .waitingForVerification
            }
        }
    }
    
    func determineAndNavigateDestination(from region: RegionResponse?, hasSeenLanding: Bool = false, animated: Bool) {
        let destination = self.determineDestination(from: region, hasSeenLanding: hasSeenLanding)
        self.navigate(to: destination, animated: true)
    }
    
    func navigate(to destination: DefaultEKYCCoordinator.Destination, animated: Bool) {
        switch destination {
        case .ekycRejected:
            self.showEKYCRejectedPage(animated: animated)
        case .goBackAndChooseCountry:
            self.delegate?.reselectCountry()
        case .success(let region):
            self.delegate?.ekycSuccessful(region: region)
        case .landing:
            self.showEKYCLandingPage(animated: animated)
        case .jumio:
            self.launchJumio(animated: animated)
        case .waitingForVerification:
            self.showWaitingForVerification(animated: animated)
        }
    }
    
    func showFirstStepAfterLanding() {
        self.determineAndNavigateDestination(from: nil,
                                             hasSeenLanding: true,
                                             animated: true)
    }
    
    func ekycRejectedRetryHandler() {
        self.determineAndNavigateDestination(from: nil,
                                             hasSeenLanding: true,
                                             animated: true)
    }
}

extension DefaultEKYCCoordinator: PendingVerificationDelegate {
    func waitingCompletedSuccessfully(for region: RegionResponse) {
        self.navigate(to: .success(region: region), animated: true)
    }
    
    func waitingCompletedWithRejection() {
        self.navigate(to: .ekycRejected, animated: true)
    }
}

extension DefaultEKYCCoordinator: JumioCoordinatorDelegate {
    
    func completedJumioSuccessfully(scanID: String) {
        let spinnerView = self.navigationController.showSpinner(onView: self.navigationController.view)
        APIManager.shared.primeAPI
            .loadContext()
            .ensure {
                self.navigationController.removeSpinner(spinnerView)
            }
            .done { context in
                let destination = self.determineDestination(from: context.getRegion(),
                                                            hasSeenLanding: true)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
                self.navigationController.showGenericError(error: error)
            }
    }
    
    func jumioScanFailed(errorMessage: String) {
        self.handleError(message: errorMessage)
    }
}
