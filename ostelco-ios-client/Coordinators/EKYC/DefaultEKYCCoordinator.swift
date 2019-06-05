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
    
    static func coordinator(for country: Country,
                            navigationController: UINavigationController) -> EKYCCoordinator {
        switch country.countryCode.lowercased() {
        case "sg":
            return SingaporeEKYCCoordinator(navigationController: navigationController)
        default:
            return DefaultEKYCCoordinator(navigationController: navigationController,
                                          country: country)
        }
    }
    
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
    
    func determineDestination(from region: RegionResponse?) -> DefaultEKYCCoordinator.Destination {
        guard let region = region else {
            return .landing
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
    
    func determineAndNavigateDestination(from region: RegionResponse?, animated: Bool) {
        let destination = self.determineDestination(from: region)
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
        self.navigate(to: .jumio, animated: true)
    }
    
    func ekycRejectedRetryHandler() {
        // Try another jumio scan.
        self.navigate(to: .jumio, animated: true)
    }
}

extension DefaultEKYCCoordinator: JumioCoordinatorDelegate {
    
    func completedJumioSuccessfully(scanID: String) {
        self.navigate(to: .waitingForVerification, animated: true)
    }
    
    func jumioScanFailed(errorMessage: String) {
        self.handleError(message: errorMessage)
    }
}
