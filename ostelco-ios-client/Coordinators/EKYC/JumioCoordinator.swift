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
    
    private let regionID: String
    private var netverifyController: NetverifyViewController?
    private var primeAPI: PrimeAPI
    
    weak var delegate: JumioCoordinatorDelegate?
    
    init(regionID: String, primeAPI: PrimeAPI) throws {
        guard !JumioDeviceInfo.isJailbrokenDevice() else {
            // Prevent SDK from being initialized on Jailbroken devices
            throw Error.deviceIsJailbroken
        }
        self.regionID = regionID
        self.primeAPI = primeAPI
    }
    
    deinit {
        netverifyController?.destroy()
        netverifyController = nil
    }
    
    func startScan(from viewController: UIViewController) {
        createScanID()
            .map { [weak self] in
                self?.createNetverifyController(with: $0)
            }
            .done { netverifyVC in
                if let netverifyVC = netverifyVC {
                    viewController.present(netverifyVC, animated: true, completion: nil)
                }
            }
            .catch { [weak self] error in
                ApplicationErrors.log(error)
                self?.delegate?.scanFailed(errorMessage: error.localizedDescription)
            }
    }

    private func createScanID() -> Promise<String> {
        return primeAPI.createJumioScanForRegion(code: regionID)
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
        config.preselectedCountry = Country(regionID).threeLetterCountryCode
        
        configureJumioAppearance()
        
        let controller = NetverifyViewController(configuration: config)
        self.netverifyController = controller
        return controller
    }
    
    private func configureJumioAppearance() {
        // NavigationBar tintColor
        UINavigationBar.jumioAppearance().tintColor = OstelcoColor.controlTint.toUIColor

        // NavigationBar titleColor
        UINavigationBar.jumioAppearance().titleTextAttributes = [.foregroundColor: OstelcoColor.textHeading.toUIColor]

        // General appearance - deactivate blur
        NetverifyBaseView.jumioAppearance().disableBlur = true

        // General appearance - background color
        NetverifyBaseView.jumioAppearance().backgroundColor = OstelcoColor.background.toUIColor

        // General appearance - foreground color
        NetverifyBaseView.jumioAppearance().foregroundColor = OstelcoColor.text.toUIColor

        // Document Selection Button (State: Normal) - Background Color
        NetverifyDocumentSelectionButton.jumioAppearance().setBackgroundColor(OstelcoColor.background.toUIColor, for: .normal)

        // Document Selection Button (State: Normal) - Icon Color
        NetverifyDocumentSelectionButton.jumioAppearance().setIconColor(OstelcoColor.secondaryButtonLabel.toUIColor, for: .normal)

        // Document Selection Button (State: Normal) - Title Color
        NetverifyDocumentSelectionButton.jumioAppearance().setTitleColor(OstelcoColor.secondaryButtonLabel.toUIColor, for: .normal)

        // Document Selection Header (State: Normal) - Background Color
        NetverifyDocumentSelectionHeaderView.jumioAppearance().backgroundColor = OstelcoColor.background.toUIColor

        // Document Selection Header (State: Normal) - Icon Color
        NetverifyDocumentSelectionHeaderView.jumioAppearance().iconColor = OstelcoColor.text.toUIColor

        // Document Selection Header (State: Normal) - Title Color
        NetverifyDocumentSelectionHeaderView.jumioAppearance().titleColor = OstelcoColor.text.toUIColor

        // Positive Button - Background Color
        NetverifyPositiveButton.jumioAppearance().setBackgroundColor(OstelcoColor.primaryButtonBackground.toUIColor, for: .normal)

        // Positive Button - Title Color
        NetverifyPositiveButton.jumioAppearance().setTitleColor(OstelcoColor.primaryButtonLabel.toUIColor, for: .normal)

        // Negative Button - Title Color
        NetverifyNegativeButton.jumioAppearance().setTitleColor(OstelcoColor.secondaryButtonLabel.toUIColor, for: .normal)

        // Fallback Button Title Color
        NetverifyFallbackButton.jumioAppearance().setTitleColor(OstelcoColor.secondaryButtonLabel.toUIColor, for: .normal)

        // Color Overlay Standard Color
        NetverifyScanOverlayView.jumioAppearance().colorOverlayStandard = OstelcoColor.highlighted.toUIColor

        // Overlay Background Color
        NetverifyScanOverlayView.jumioAppearance().scanBackgroundColor = OstelcoColor.fog.toUIColor

        // Face Feedback Text Color
        NetverifyScanOverlayView.jumioAppearance().faceFeedbackTextColor = OstelcoColor.foreground.toUIColor

        // General appearance - deactivate blur
        JumioBaseView.jumioAppearance().disableBlur = true

        // General appearance - background color
        JumioBaseView.jumioAppearance().backgroundColor = OstelcoColor.background.toUIColor

        // General appearance - foreground color
        JumioBaseView.jumioAppearance().foregroundColor = OstelcoColor.text.toUIColor

        // Positive Button - Background Color
        JumioPositiveButton.jumioAppearance().setBackgroundColor(OstelcoColor.primaryButtonBackground.toUIColor, for: .normal)

        // Positive Button - Title Color
        JumioPositiveButton.jumioAppearance().setTitleColor(OstelcoColor.primaryButtonLabel.toUIColor, for: .normal)

        // Negative Button - Title Color
        JumioNegativeButton.jumioAppearance().setTitleColor(OstelcoColor.secondaryButtonLabel.toUIColor, for: .normal)

        // Face Feedback Text Color
        JumioScanOverlayView.jumioAppearance().faceFeedbackTextColor = OstelcoColor.foreground.toUIColor
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
