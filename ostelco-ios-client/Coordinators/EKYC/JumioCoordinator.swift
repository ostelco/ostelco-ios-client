//
//  JumioCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Netverify
import ostelco_core
import OstelcoStyles
import PromiseKit

protocol JumioCoordinatorDelegate: class {
    func completedJumioSuccessfully(scanID: String)
    func jumioScanFailed(errorMessage: String)
}

class JumioCoordinator: NSObject {
    
    enum Error: Swift.Error, LocalizedError {
        case deviceIsJailbroken
        
        var localizedDescription: String {
            switch self {
            case .deviceIsJailbroken:
                return "Sorry, we do not support identity verification on jailbroken devices."
            }
        }
    }
    
    private let country: Country
    
    weak var delegate: JumioCoordinatorDelegate?
    
    init(country: Country) throws {
        guard !JumioDeviceInfo.isJailbrokenDevice() else {
            // Prevent SDK from being initialized on Jailbroken devices
            throw Error.deviceIsJailbroken
        }
        
        self.country = country
    }
    
    func startScan(from viewController: UIViewController) {
        self.getNewScanID()
            .map { self.createNetverifyController(with: $0) }
            .done { netverifyVC in
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    // For iPad, present from sheet
                    netverifyVC.modalPresentationStyle = .formSheet
                }
                viewController.present(netverifyVC, animated: true, completion: nil)
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.delegate?.jumioScanFailed(errorMessage: error.localizedDescription)
            }
    }

    private func getNewScanID() -> Promise<String> {
        let countryCode = self.country.countryCode.lowercased()
        return APIManager.shared.primeAPI
            .createJumioScanForRegion(code: countryCode)
            .map { scan in
                return scan.scanId
            }
    }
        
    private func createNetverifyController(with scanID: String) -> NetverifyViewController {
        // Setup the Configuration for Netverify - use tokens from JUMIO console
        let config: NetverifyConfiguration = NetverifyConfiguration()
        config.apiToken = Environment().configuration(.JumioToken)
        config.apiSecret = Environment().configuration(.JumioSecret)
        
        config.customerInternalReference = scanID
        config.enableVerification = true
        config.enableIdentityVerification = true
        config.delegate = self
        
        // This must be a 3-letter code following ISO-3166
        config.preselectedCountry = self.country.threeLetterCountryCode
        
        // General appearance
        NetverifyBaseView.jumioAppearance().disableBlur = true
        NetverifyBaseView.jumioAppearance().backgroundColor = OstelcoColor.white.toUIColor
        NetverifyPositiveButton.jumioAppearance().setBackgroundColor(
            OstelcoColor.oyaBlue.toUIColor,
            for: .normal
        )
        
        return NetverifyViewController(configuration: config)
    }
}

extension JumioCoordinator: NetverifyViewControllerDelegate {
    func netverifyViewController(_ netverifyViewController: NetverifyViewController,
                                 didFinishWith documentData: NetverifyDocumentData,
                                 scanReference: String) {
        
        debugPrint("NetverifyViewController finished successfully with scan reference: \(scanReference)")
        let message = documentData.toOstelcoString()
        debugPrint(message)
        netverifyViewController.dismiss(animated: true) {
            netverifyViewController.destroy()
            self.delegate?.completedJumioSuccessfully(scanID: scanReference)
        }
    }
    
    func netverifyViewController(_ netverifyViewController: NetverifyViewController,
                                 didCancelWithError error: NetverifyError?,
                                 scanReference: String?) {
        debugPrint("NetverifyViewController cancelled with error: \(error?.message ?? "") scanReference: \(scanReference ?? "")")
        
        netverifyViewController.dismiss(animated: true) {
            netverifyViewController.destroy()
            self.delegate?.jumioScanFailed(errorMessage: "\(error?.message ?? "An unknown error occurred.")")
        }
    }
}
