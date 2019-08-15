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
    func scanSucceeded(scanID: String)
    func scanCancelled()
    func scanFailed(errorMessage: String)
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
    private var netverifyController: NetverifyViewController?
    private var primeAPI: PrimeAPI
    
    weak var delegate: JumioCoordinatorDelegate?
    
    init(country: Country, primeAPI: PrimeAPI) throws {
        guard !JumioDeviceInfo.isJailbrokenDevice() else {
            // Prevent SDK from being initialized on Jailbroken devices
            throw Error.deviceIsJailbroken
        }
        
        self.country = country
        self.primeAPI = primeAPI
    }
    
    deinit {
        netverifyController?.destroy()
    }
    
    func startScan(from viewController: UIViewController) {
        createScanID()
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
                self?.delegate?.scanFailed(errorMessage: error.localizedDescription)
            }
    }

    private func createScanID() -> Promise<String> {
        let countryCode = self.country.countryCode.lowercased()
        return primeAPI
            .createJumioScanForRegion(code: countryCode)
            .map { scan in
                return scan.scanId
            }
    }
        
    private func createNetverifyController(with scanID: String) -> NetverifyViewController {
        // Setup the Configuration for Netverify - use tokens from JUMIO console
        let config: NetverifyConfiguration = NetverifyConfiguration()
        let environment = Environment()
        config.apiToken = environment.configuration(.JumioToken)
        config.apiSecret = environment.configuration(.JumioSecret)
        
        config.customerInternalReference = scanID
        config.enableVerification = true
        config.enableIdentityVerification = true
        config.delegate = self
        
        // This must be a 3-letter code following ISO-3166
        config.preselectedCountry = country.threeLetterCountryCode
        
        // General appearance
        let baseAppearance = NetverifyBaseView.jumioAppearance()
        baseAppearance.disableBlur = true
        baseAppearance.backgroundColor = OstelcoColor.background.toUIColor
        NetverifyPositiveButton.jumioAppearance().setBackgroundColor(OstelcoColor.oyaBlue.toUIColor, for: .normal)
        
        let controller = NetverifyViewController(configuration: config)
        self.netverifyController = controller
        return controller
    }
}

extension JumioCoordinator: NetverifyViewControllerDelegate {
    func netverifyViewController(_ netverifyViewController: NetverifyViewController,
                                 didFinishWith documentData: NetverifyDocumentData,
                                 scanReference: String) {
        
        debugPrint("NetverifyViewController finished successfully with scan reference: \(scanReference)")
        let message = documentData.toOstelcoString()
        debugPrint(message)
        delegate?.scanSucceeded(scanID: scanReference)
    }
    
    func netverifyViewController(_ netverifyViewController: NetverifyViewController,
                                 didCancelWithError error: NetverifyError?,
                                 scanReference: String?) {
        debugPrint("NetverifyViewController cancelled with error: \(error?.message ?? "") scanReference: \(scanReference ?? "")")
        if let error = error {
            switch error.code {
            case "G00000": // User cancelled the scan
                delegate?.scanCancelled()
            default:
                delegate?.scanFailed(errorMessage: "\(error.message ?? "An unknown error occurred.")")
            }
        }
    }
}
