//
//  SingaporeEKYCCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

class SingaporeEKYCCoordinator: EKYCCoordinator {
    enum Destination {
        case goBackAndChooseCountry
        case landing
        case selectVerificationMethod
        case jumio
        case singPass
        case editSingPassAddress(address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate)
        case verifySingPassAddress(queryItems: [URLQueryItem])
        case enterAddress
        case stepsForNRIC
        case enterNRIC
        case ekycRejected
        case success(region: RegionResponse)
        case waitingForVerification
    }
    
    let navigationController: UINavigationController
    
    weak var delegate: EKYCCoordinatorDelegate?
    var jumioCoordinator: JumioCoordinator?
    var singPassCoordinator: SingPassCoordinator?
    let country = Country("sg")
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func determineAndNavigateDestination(from region: RegionResponse?, hasSeenLanding: Bool = false, animated: Bool) {
        let destination = self.determineDestination(from: region, hasSeenLanding: hasSeenLanding)
        self.navigate(to: destination, animated: animated)
    }
    
    func determineDestination(from region: RegionResponse?, hasSeenLanding: Bool = false) -> SingaporeEKYCCoordinator.Destination {
        guard let region = region else {
            if hasSeenLanding {
                return .selectVerificationMethod
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
            guard
                let jumio = region.kycStatusMap.JUMIO,
                let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER,
                let nricFin = region.kycStatusMap.NRIC_FIN,
                let myInfo = region.kycStatusMap.MY_INFO else {
                    return .goBackAndChooseCountry
            }
            
            switch (jumio, addressAndPhoneNumber, nricFin, myInfo) {
            case (.PENDING, .PENDING, .PENDING, .PENDING):
                // User hasn't selected anything yet
                return .selectVerificationMethod
            case (.REJECTED, _, _, _):
                // If jumio is rejected, *everything* is rejected.
                return .ekycRejected
            case (_, _, _, .REJECTED):
                // If myInfo is rejected, *everything* is rejected
                return .ekycRejected
            case (.APPROVED, .APPROVED, .APPROVED, _):
                // Jumio + addresss + NRCFIN = Yay!
                return .success(region: region)
            case (_, .APPROVED, _, .APPROVED):
                // MyInfo + address = yay!
                return .success(region: region)
            case (_, .PENDING, _, .APPROVED):
                // My info also needs an address submitted, but we've probably lost
                // what we need to access their singpass address. Make the user enter it.
                return .enterAddress
            case (.PENDING, .PENDING, .APPROVED, _):
                // The user has an approved NRIC. Now we need Jumio verification and an address. Start with jumio.
                return .jumio
            case (.PENDING, .APPROVED, .APPROVED, _):
                // The user has an approved NRIC and address, now we need Jumio verification.
                return .jumio
            case (.APPROVED, .PENDING, .APPROVED, _):
                // The user has an approved NRIC and verified with jumio, now we need an address.
                return .enterAddress
            case (.PENDING, .APPROVED, .PENDING, _):
                // The user has an approved addresss, but we still need something else.
                return .selectVerificationMethod
            default:
                // The user has gotten into some bizarre state and should try again.
                return .goBackAndChooseCountry
            }
        }
    }
    
    func navigate(to destination: SingaporeEKYCCoordinator.Destination, animated: Bool) {
        switch destination {
        case .stepsForNRIC:
            let stepsVC = ScanICStepsViewController.fromStoryboard()
            stepsVC.coordinator = self
            self.navigationController.pushViewController(stepsVC, animated: true)
        case .enterAddress:
            let addressEdit = AddressEditViewController.fromStoryboard()
            addressEdit.mode = .nricEdit
            addressEdit.coordinator = self
            self.navigationController.setViewControllers([addressEdit], animated: animated)
        case .editSingPassAddress(let address, let delegate):
            let addressEdit = AddressEditViewController.fromStoryboard()
            addressEdit.mode = .myInfoVerify(myInfo: address)
            addressEdit.myInfoDelegate = delegate
            self.navigationController.pushViewController(addressEdit, animated: animated)
        case .selectVerificationMethod:
            let selectVerificationMethodVC = SelectIdentityVerificationMethodViewController.fromStoryboard()
            selectVerificationMethodVC.coordinator = self
            self.navigationController.pushViewController(selectVerificationMethodVC, animated: animated)
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
        case .enterNRIC:
            let nricVC = NRICVerifyViewController.fromStoryboard()
           nricVC.coordinator = self
            self.navigationController.pushViewController(nricVC, animated: animated)
        case .singPass:
            let singPassCoordinator = SingPassCoordinator()
            singPassCoordinator.delegate = self
            singPassCoordinator.startLogin(from: self.navigationController)
            self.singPassCoordinator = singPassCoordinator
        case .verifySingPassAddress(let queryItems):
            let myInfoSummary = MyInfoSummaryViewController.fromStoryboard()
            myInfoSummary.myInfoQueryItems = queryItems
            self.navigationController.setViewControllers([myInfoSummary], animated: animated)
        case .waitingForVerification:
            self.showWaitingForVerification(animated: animated)
        }
    }
    
    func ekycRejectedRetryHandler() {
        // Let the user reselect a validation method
        self.navigate(to: .selectVerificationMethod, animated: true)
    }
    
    func showFirstStepAfterLanding() {
        self.navigate(to: .selectVerificationMethod, animated: true)
    }
    
    private func updateRegionAndNavigate(animated: Bool) {
        APIManager.shared.primeAPI
            .loadRegion(code: self.country.countryCode)
            .done { region in
                let destination = self.determineDestination(from: region)
                self.navigate(to: destination, animated: animated)
            }
            .catch { error in
                ApplicationErrors.log(error)
        }
    }
    
    // MARK: - SingPass flow
    
    func determineSingPassFlowDestination(singPassQueryItems: [URLQueryItem]? = nil,
                                          address: MyInfoAddress? = nil,
                                          editDelegate: MyInfoAddressUpdateDelegate? = nil) -> SingaporeEKYCCoordinator.Destination {
        
        if let delegate = editDelegate {
            return .editSingPassAddress(address: address, delegate: delegate)
        }
        
        if let queryItems = singPassQueryItems {
            return .verifySingPassAddress(queryItems: queryItems)
        }
        
        return .singPass
    }
    
    func selectedSingPass() {
        let destination = self.determineSingPassFlowDestination()
        self.navigate(to: destination, animated: true)
    }
    
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate) {
        let destination = self.determineSingPassFlowDestination(singPassQueryItems: nil, address: address, editDelegate: delegate)
        self.navigate(to: destination, animated: true)
    }
    
    func verifiedSingPassAddress() {
        self.updateRegionAndNavigate(animated: true)
    }
    
    // MARK: - NRIC / Jumio / Address flow
    
    func determineNRICFlowDestination(viewedSteps: Bool = false,
                                      validatedNRIC: Bool = false,
                                      completedJumio: Bool = false) -> SingaporeEKYCCoordinator.Destination {
        guard viewedSteps else {
            return .stepsForNRIC
        }
        
        guard validatedNRIC else {
            return .enterNRIC
        }
        
        guard completedJumio else {
            return .jumio
        }
        
        return .enterAddress
    }
    
    func selectedNRIC() {
        let destination = self.determineNRICFlowDestination()
        self.navigate(to: destination, animated: true)
    }
    
    func finishedViewingNRICSteps() {
        let destination = self.determineNRICFlowDestination(viewedSteps: true)
        self.navigate(to: destination, animated: true)
    }
    
    func enteredNRICSuccessfully() {
        let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                            validatedNRIC: true)
        self.navigate(to: destination, animated: true)
    }

    func enteredAddressSuccessfully() {
        self.updateRegionAndNavigate(animated: true)
    }
}

extension SingaporeEKYCCoordinator: JumioCoordinatorDelegate {
    
    func completedJumioSuccessfully(scanID: String) {
        let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                            validatedNRIC: true,
                                                            completedJumio: true)
        self.navigate(to: destination, animated: true)
    }
    
    func jumioScanFailed(errorMessage: String) {
        self.handleError(message: errorMessage)
    }
}

extension SingaporeEKYCCoordinator: SingPassCoordinatorDelegate {
    
    func signInSucceeded(myInfoQueryItems: [URLQueryItem]) {
        self.navigationController.dismiss(animated: true)
        let destination = self.determineSingPassFlowDestination(singPassQueryItems: myInfoQueryItems)
        self.navigate(to: destination, animated: true)
    }
    
    func signInFailed(error: NSError?) {
        // TODO: This wasn't handled before, do we need to do anything here?
        debugPrint("Error: \(String(describing: error))")
    }
}
