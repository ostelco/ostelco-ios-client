//
//  SingaporeEKYCCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UIKit

class SingaporeEKYCCoordinator: EKYCCoordinator {
    enum Destination {
        case goBackAndChooseCountry
        case landing
        case selectVerificationMethod
        case jumio
        case singPass
        case editSingPassAddress(address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate)
        case verifySingPassAddress
        case enterAddress(hasCompletedJumio: Bool)
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
    private var cachedRegion: RegionResponse?
    
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
            case (_, .REJECTED, _, _), // Address rejected
                (.REJECTED, _, _, .REJECTED), // Jumio + SingPass rejected
                (_, _, .REJECTED, .REJECTED): // NRIC + SingPass rejected
                // In any of these cases, there's no way forward to being approved
                // without either a) resubmitting to something that has already been rejected,
                // which will confuse the backend, or b) starting over. So:
                return .ekycRejected
            case (.REJECTED, _, _, _), // jumio rejected
                 (_, _, .REJECTED, _): // NRIC rejected
                // User can only do singPass at this point
                return self.determineSingPassFlowDestination(region: region)
            case (_, _, _, .REJECTED):
                // Singpass has been rejected, user can only still do NRIC
                // They had to have seen the steps if one of these is true.
                let viewedSteps = (jumio == .APPROVED || addressAndPhoneNumber == .APPROVED || nricFin == .APPROVED)
                return self.determineNRICFlowDestination(viewedSteps: viewedSteps,
                                                         region: region)
            case (_, _, _, .APPROVED):
                // User has done SingPass, so they want singPass flow
                let destination = self.determineSingPassFlowDestination(region: region)
                return destination
            case (.APPROVED, _, _, _):
                // User has done jumio, so they want NRIC flow
                return self.determineNRICFlowDestination(viewedSteps: true,
                                                         region: region,
                                                         completedJumio: true)
            
            case (_, _, .APPROVED, _):
                // User has done NRIC, so they want that flow
                return self.determineNRICFlowDestination(viewedSteps: true,
                                                         region: region)
            case (.PENDING, .APPROVED, .PENDING, _):
                // The user has an approved addresss, but we still need something else.
                return .selectVerificationMethod
            }
        }
    }
    
    func navigate(to destination: SingaporeEKYCCoordinator.Destination, animated: Bool) {
        switch destination {
        case .stepsForNRIC:
            let stepsVC = ScanICStepsViewController.fromStoryboard()
            stepsVC.coordinator = self
            self.navigationController.pushViewController(stepsVC, animated: true)
        case .enterAddress(let hasCompletedJumio):
            let addressEdit = AddressEditViewController.fromStoryboard()
            addressEdit.mode = .nricEnter(hasCompletedJumio: hasCompletedJumio)
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
            
            // Add the steps VC underneath jumio so there's something if the user cancels
            let stepsVC = ScanICStepsViewController.fromStoryboard()
            stepsVC.coordinator = self
            self.navigationController.setViewControllers([stepsVC], animated: animated)
        case .enterNRIC:
            let nricVC = NRICVerifyViewController.fromStoryboard()
            nricVC.coordinator = self
            self.navigationController.pushViewController(nricVC, animated: animated)
        case .singPass:
            let singPassCoordinator = SingPassCoordinator()
            singPassCoordinator.delegate = self
            singPassCoordinator.startLogin(from: self.navigationController)
            self.singPassCoordinator = singPassCoordinator
        case .verifySingPassAddress:
            let myInfoSummary = MyInfoSummaryViewController.fromStoryboard()
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
    
    func waitingCompletedSuccessfully(for region: RegionResponse) {
        self.navigate(to: .success(region: region), animated: true)
    }
    
    func waitingCompletedWithRejection() {
        self.navigate(to: .ekycRejected, animated: true)
    }
    
    private func getCachedOrUpdateRegion() -> Promise<RegionResponse> {
        if let cached = self.cachedRegion {
            return .value(cached)
        } else {
            return self.updateRegion()
        }
    }
    
    private func updateRegion() -> Promise<RegionResponse> {
        return APIManager.shared.primeAPI
            .loadRegion(code: self.country.countryCode)
            .map { [weak self] region -> RegionResponse in
                self?.cachedRegion = region
                return region
            }
    }
    
    // MARK: - SingPass flow
    
    func determineSingPassFlowDestination(region: RegionResponse?,
                                          address: MyInfoAddress? = nil,
                                          editDelegate: MyInfoAddressUpdateDelegate? = nil) -> SingaporeEKYCCoordinator.Destination {
        guard let region = region else {
            return .singPass
        }
        
        guard
            let myInfoStatus = region.kycStatusMap.MY_INFO,
            let addressStatus = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER else {
                return .goBackAndChooseCountry
        }

        switch (myInfoStatus, addressStatus) {
        case (.REJECTED, _),
             (_, .REJECTED):
            return .ekycRejected
        case (.PENDING, _):
            // User has not yet logged into SingPass.
            return .singPass
        case (.APPROVED, .APPROVED):
            return .success(region: region)
        case (.APPROVED, .PENDING):
            if let delegate = editDelegate {
                return .editSingPassAddress(address: address, delegate: delegate)
            } else {
                return .verifySingPassAddress
            }
        }
    }

    func selectedSingPass() {
        self.getCachedOrUpdateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineSingPassFlowDestination(region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                switch error {
                case APIHelper.Error.jsonError(let error):
                    if error.errorCode == "FAILED_TO_FETCH_REGIONS" {
                        // The user hasn't created a region
                        let destination = self.determineSingPassFlowDestination(region: nil)
                        self.navigate(to: destination, animated: true)
                        return
                } // else, keep going
                default:
                    break
                }
                ApplicationErrors.log(error)
            }
    }
    
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate) {
        self.getCachedOrUpdateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineSingPassFlowDestination(region: region,
                                                                        address: address,
                                                                        editDelegate: delegate)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func verifiedSingPassAddress() {
        self.updateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineSingPassFlowDestination(region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    // MARK: - NRIC / Jumio / Address flow
    
    func determineNRICFlowDestination(viewedSteps: Bool = false,
                                      region: RegionResponse?,
                                      completedJumio: Bool = false) -> SingaporeEKYCCoordinator.Destination {
        guard viewedSteps else {
            return .stepsForNRIC
        }
        
        guard let region = region else {
            // We don't even have a region - make the user enter an NRIC
            return .enterNRIC
        }
        
        guard
            let jumioStatus = region.kycStatusMap.JUMIO,
            let addressStatus = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER,
            let nricStatus = region.kycStatusMap.NRIC_FIN else {
                return .goBackAndChooseCountry
        }
        
        switch (jumioStatus, addressStatus, nricStatus) {
        case (.REJECTED, _, _),
             (_, .REJECTED, _),
             (_, _, .REJECTED):
            return .ekycRejected
        case (.APPROVED, .APPROVED, .APPROVED):
            return .success(region: region)
        case (_, _, .PENDING):
            // We don't have an NRIC and we need one.
            return .enterNRIC
        case (.PENDING, .PENDING, .APPROVED):
            if completedJumio {
                // The user completed jumio and is still waiting for verification, we still need an address though
                return .enterAddress(hasCompletedJumio: true)
            } else {
                // The user has not completed jumio and they need to
                return .jumio
            }
        case (.PENDING, .APPROVED, .APPROVED):
            if completedJumio {
                // Now we're just waiting for jumio to be approved.
                return .waitingForVerification
            } else {
                // We still need the user to do jumio things
                return .jumio
            }
        case (.APPROVED, .PENDING, .APPROVED):
            // The user has an approved NRIC and verified with jumio, now we need an address.
            return .enterAddress(hasCompletedJumio: true)
        }
    }
    
    func finishedViewingNRICSteps() {
        self.getCachedOrUpdateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                    region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                    ApplicationErrors.log(error)
            }
    }
    
    func selectedNRIC() {
        self.getCachedOrUpdateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                    region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                switch error {
                case APIHelper.Error.jsonError(let error):
                    if error.errorCode == "FAILED_TO_FETCH_REGIONS" {
                        // The user hasn't created a region
                        let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                            region: nil)
                        self.navigate(to: destination, animated: true)
                        return
                    } // else, keep going
                default:
                    break
                }
                
                ApplicationErrors.log(error)
            }
    }
    
    func enteredNRICSuccessfully() {
        self.updateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                    region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }

    func enteredAddressSuccessfully(hasCompletedJumio: Bool) {
        self.updateRegion()
            .done { [weak self] region in
                guard let self = self else {
                    return
                }
                
                let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                    region: region,
                                                                    completedJumio: hasCompletedJumio)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
}

extension SingaporeEKYCCoordinator: JumioCoordinatorDelegate {
    
    func completedJumioSuccessfully(scanID: String) {
        self.updateRegion()
            .done { region in
                let destination = self.determineNRICFlowDestination(viewedSteps: true,
                                                                    region: region,
                                                                    completedJumio: true)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func jumioScanFailed(errorMessage: String) {
        self.handleError(message: errorMessage)
    }
}

extension SingaporeEKYCCoordinator: SingPassCoordinatorDelegate {
    
    func signInSucceeded(myInfoQueryItems: [URLQueryItem]) {
        self.navigationController.dismiss(animated: true)
        self.updateRegion()
            .done { region in
                let destination = self.determineSingPassFlowDestination(region: region)
                self.navigate(to: destination, animated: true)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func signInFailed(error: NSError?) {
        // TODO: This wasn't handled before, do we need to do anything here?
        debugPrint("Error: \(String(describing: error))")
    }
}
