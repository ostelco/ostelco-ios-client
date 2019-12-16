//// Created for ostelco-ios-client in 2019

import Foundation
import PromiseKit
import AVFoundation

extension RegionOnboardingCoordinator: SelectIdentityVerificationMethodDelegate {
    func selected(option: IdentityVerificationOption) {
        localContext.selectedVerificationOption = option
        OstelcoAnalytics.logEvent(.identificationMethodChosen(regionCode: region.region.id, countryCode: LocationController.shared.currentCountry?.countryCode ?? "", ekycMethod: option.rawValue))
        switch option {
        case .scanIC, .jumio:
            checkCameraAccess {
                self.advance()
            }
        default:
            advance()
        }
        
    }
}

extension RegionOnboardingCoordinator: SingPassCoordinatorDelegate {
    func signInSucceeded(myInfoQueryItems: [URLQueryItem]) {
        let code = myInfoQueryItems.first(where: { $0.name == "code" })?.value
        localContext.myInfoCode = code
        advance()
    }
    
    func signInFailed(error: NSError?) {
        print(error ?? "no error")
    }
}

extension RegionOnboardingCoordinator: MyInfoSummaryDelegate {
    func fetchMyInfoDetails(_ controller: MyInfoSummaryViewController, code: String, completion: @escaping (MyInfoDetails) -> Void) {
        let spinnerView = controller.showSpinner(loadingText: NSLocalizedString("Loading your data from SingPass...", comment: "Loading text after user approves SingPass"))
        primeAPI.loadSingpassInfo(code: code)
            .ensure {
                controller.removeSpinner(spinnerView)
        }
        .done { myInfoDetails in
            completion(myInfoDetails)
        }
        .catch { error in
            ApplicationErrors.log(error)
            controller.showGenericError(error: error) { [weak self] (_) in
                self?.localContext.selectedVerificationOption = nil
                self?.advance()
            }
        }
    }
    
    func updateProfile(_ controller: MyInfoSummaryViewController, profile: EKYCProfileUpdate) {
        let spinnerView = controller.showSpinner()
        let regionCode = controller.regionCode
        
        primeAPI.updateEKYCProfile(with: profile, forRegion: regionCode!)
            .ensure {
                controller.removeSpinner(spinnerView)
        }
        .done { [weak self] in
            self?.advance()
        }
        .catch { error in
            ApplicationErrors.log(error)
            controller.showGenericError(error: error) { [weak self] (_) in
                self?.localContext.selectedVerificationOption = nil
                self?.advance()
            }
        }
    }
    
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate) {
        let addressController = AddressEditViewController.fromStoryboard()
        addressController.mode = .myInfoVerify(myInfo: address)
        addressController.myInfoDelegate = delegate
        addressController.delegate = self
        navigationController.pushViewController(addressController, animated: true)
    }
}

extension RegionOnboardingCoordinator: AddressEditDelegate {
    func entered(address: EKYCAddress, regionCode: String) {
        primeAPI
        .addAddress(address, forRegion: regionCode)
        .done { [weak self] in
            self?.advance()
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
    }
    
    func cancel() {
        navigationController.popViewController(animated: true)
    }
}

extension RegionOnboardingCoordinator: ESIMInstructionsDelegate {
    func completedInstructions(_ controller: ESIMInstructionsViewController) {
        OstelcoAnalytics.logEvent(.esimSetupStarted(regionCode: region.region.id, countryCode: LocationController.shared.currentCountry?.countryCode ?? ""))
        let spinner = controller.showSpinner()
        
        makeSimProfileForRegion(region.region.id)
        .then({ simProfile in
            self.installESimProfile(controller: controller, simProfile: simProfile)
        })
        .then({ profile in
            self.primeAPI.markESIMAsInstalled(simProfile: profile)
        })
        .ensure {
            controller.removeSpinner(spinner)
        }
        .done { [weak self] _ in
            OstelcoAnalytics.logEvent(.esimSetupCompleted(regionCode: self?.region.region.id ?? "", countryCode: LocationController.shared.currentCountry?.countryCode ?? ""))
            self?.localContext.hasSeenESIMInstructions = true
            self?.advance()
        }
        .catch { error in
            OstelcoAnalytics.logEvent(.esimSetupFailed(regionCode: self.region.region.id, countryCode: LocationController.shared.currentCountry?.countryCode ?? ""))
            ApplicationErrors.log(error)
            controller.showAlert(title: "Error", msg: error.localizedDescription)
        }
    }
    
    func installESimProfile(controller: UIViewController, simProfile: SimProfile) -> PromiseKit.Promise<SimProfile> {
        switch simProfile.status {
        case .INSTALLED:
            return PromiseKit.Promise.value(simProfile)
        case .AVAILABLE_FOR_DOWNLOAD:
            if simProfile.isDummyProfile {
                return PromiseKit.Promise<SimProfile> { seal in
                    controller.showAlert(title: "YOU DID NOT GET AN ESIM", msg: "Triggered fake eSIM path, which means you don't install an eSIM on your phone but we let you pass through the onboarding pretending you have one. This message should only be visible to testers.") { _ in
                        seal.fulfill(simProfile)
                    }
                }
                
            }
            guard simProfile.hasValidESimActivationCode() else {
                fatalError("Invalid ESim activation code, could not find esim server address or activation code from: \(simProfile.eSimActivationCode)")
            }
            return self.esimManager.addPlan(address: simProfile.eSimServerAddress, matchingID: simProfile.matchingID, simProfile: simProfile)
        default:
            fatalError("Invalid simProfile status, expected \(SimProfileStatus.AVAILABLE_FOR_DOWNLOAD) or \(SimProfileStatus.INSTALLED) got: \(simProfile.status)")
        }
    }
}

extension RegionOnboardingCoordinator: NRICVerifyDelegate {
    func enteredNRICS(_ controller: NRICVerifyViewController, nric: String) {
        let spinnerView = controller.showSpinner()
        primeAPI
            .validateNRIC(nric, forRegion: region.region.id)
            .ensure {
                controller.removeSpinner(spinnerView)
        }
        .done { [weak self] isValid in
            if isValid {
                self?.advance()
            } else {
                controller.showError()
            }
        }
        .catch { error in
            ApplicationErrors.log(error)
            controller.showGenericError(error: error)
        }
    }
    
    func enteredNRICSuccessfully() {
        advance()
    }
}

extension RegionOnboardingCoordinator: JumioCoordinatorDelegate {
    func scanSucceeded(scanID: String) {
        afterDismissing { [weak self] in
            self?.localContext.hasCompletedJumio = true
            self?.jumioCoordinator = nil
            self?.advance()
        }
    }
    
    func scanCancelled() {
        afterDismissing { [weak self] in
            self?.jumioCoordinator = nil
            self?.delegate?.onboardingCancelled()
        }
    }
    
    func scanFailed(errorMessage: String) {
        afterDismissing { [weak self] in
            self?.jumioCoordinator = nil
            self?.localContext.selectedVerificationOption = nil
            self?.advance()
        }
    }
}

extension RegionOnboardingCoordinator: PendingVerificationDelegate {
    func checkStatus() {
        advance()
    }
    
    func reportAnalytics() {
        OstelcoAnalytics.logEvent(.identificationPendingValidation(regionCode: region.region.id, countryCode: LocationController.shared.currentCountry?.countryCode ?? "", ekycMethod: localContext.selectedVerificationOption?.rawValue ?? ""))
    }
}

extension RegionOnboardingCoordinator: AllowCameraAccessDelegate {
    func cameraUsageAuthorized() {
        advance()
    }
    
    func chooseAnotherMethod() {
        localContext.selectedVerificationOption = nil
        advance()
    }
}

extension RegionOnboardingCoordinator: SignUpCompletedDelegate {
    func regionName() -> String {
        region.region.name
    }
    
    func acknowledgedSuccess() {
        localContext.hasSeenAwesome = true
        advance()
    }
}

protocol RegionOnboardingDelegate: class {
    func onboardingCompleteForRegion(_ regionID: String)
    func onboardingCancelled()
}

class RegionOnboardingCoordinator {
    let region: PrimeGQL.RegionDetailsFragment
    var localContext: RegionOnboardingContext
    let navigationController: UINavigationController
    let primeAPI: PrimeAPI
    let stageDecider = StageDecider()
    let esimManager = ESimManager()
    let targetCountry: Country
    
    public weak var delegate: RegionOnboardingDelegate?
    
    var singpassCoordinator: SingPassCoordinator?
    var jumioCoordinator: JumioCoordinator?
    
    init(region: PrimeGQL.RegionDetailsFragment, targetCountry: Country, localContext: RegionOnboardingContext, navigationController: UINavigationController, primeAPI: PrimeAPI) {
        self.region = region
        self.targetCountry = targetCountry
        self.localContext = localContext
        self.navigationController = navigationController
        self.primeAPI = primeAPI
        
        advance()
    }
    
    func advance() {
        primeAPI.loadContext()
        .done { (context) in
            assert(Thread.isMainThread)
            
            self.localContext.serverIsUnreachable = false
            
            UserManager.shared.customer = context.customer
            
            let regionFragment = context.regions.map {
                $0.fragments.regionDetailsFragment
            }.first(where: {
                $0.region.id == self.region.region.id
            })!
            
            let region = RegionResponse(gqlData: regionFragment)
            let stage: StageDecider.RegionStage
            let targetCountry = self.targetCountry
            
            if let problem = self.checkLocation(country: targetCountry) {
                stage = .locationProblem(problem)
            } else {
                stage = self.stageDecider.stageForRegion(
                    region: region,
                    localContext: self.localContext,
                    currentCountry: LocationController.shared.currentCountry,
                    targetCountry: targetCountry
                )
            }
            
            self.afterDismissing {
                self.navigateTo(stage)
            }
        }.cauterize()
    }
    
    private func checkLocation(country: Country) -> LocationProblem? {
        let controller = LocationController.shared
        if controller.checkInCorrectCountry(country) {
            return nil
        } else {
            return controller.locationProblem
        }
    }
    
    private func afterDismissing(completion: @escaping () -> Void) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    func navigateTo(_ stage: StageDecider.RegionStage) {
        assert(Thread.isMainThread)
        
        switch stage {
        case .caution(let current, let target):
            let controller = CautionViewController.fromStoryboard(delegate: self, current: current, target: target)
            navigationController.setViewControllers([controller], animated: true)
        case .selectIdentityVerificationMethod(let options):
            let selectEKYCMethod = SelectIdentityVerificationMethodViewController.fromStoryboard()
            selectEKYCMethod.delegate = self
            selectEKYCMethod.options = options
            navigationController.setViewControllers([selectEKYCMethod], animated: true)
        case .singpass:
            singpassCoordinator = SingPassCoordinator(delegate: self, primeAPI: primeAPI)
            singpassCoordinator?.startLogin(from: navigationController)
        case .verifyMyInfo(let code):
            let verifyMyInfo = MyInfoSummaryViewController.fromStoryboard()
            verifyMyInfo.regionCode = region.region.id
            verifyMyInfo.myInfoCode = code
            verifyMyInfo.delegate = self
            navigationController.setViewControllers([verifyMyInfo], animated: true)
        case .eSimInstructions:
            OstelcoAnalytics.logEvent(.identificationSuccessful(
                regionCode: region.region.id,
                countryCode: LocationController.shared.currentCountry?.countryCode ?? "",
                ekycMethod: localContext.selectedVerificationOption?.rawValue ?? "")
                )
            let instructions = ESIMInstructionsViewController.fromStoryboard()
            instructions.delegate = self
            navigationController.setViewControllers([instructions], animated: true)
        case .nric:
            let nric = NRICVerifyViewController.fromStoryboard()
            nric.delegate = self
            navigationController.setViewControllers([nric], animated: true)
        case .jumioInstructions:
            let instructions = JumioInstructionsViewController.fromStoryboard()
            instructions.delegate = self
            navigationController.pushViewController(instructions, animated: true)
        case .jumio:
            if let jumio = try? JumioCoordinator(regionID: region.region.id, primeAPI: primeAPI, targetCountry: targetCountry) {
                self.jumioCoordinator = jumio
                
                jumio.delegate = self
                jumio.startScan(from: navigationController)
            }
        case .address:
            let addressController = AddressEditViewController.fromStoryboard()
            addressController.mode = .nricEnter
            addressController.delegate = self
            addressController.regionCode = region.region.id
            navigationController.setViewControllers([addressController], animated: true)
        case .pendingVerification:
            OstelcoAnalytics.logEvent(.identificationPendingValidation(
                regionCode: region.region.id,
                countryCode: LocationController.shared.currentCountry?.countryCode ?? "",
                ekycMethod: localContext.selectedVerificationOption?.rawValue ?? "")
            )
            let pending = PendingVerificationViewController.fromStoryboard()
            pending.delegate = self
            navigationController.setViewControllers([pending], animated: true)
        case .cameraProblem:
            let cameraPermissions = AllowCameraAccessViewController.fromStoryboard()
            cameraPermissions.delegate = self
            navigationController.setViewControllers([cameraPermissions], animated: true)
        case .ohNo(let issue):
            let ohNo = OhNoViewController.fromStoryboard(type: issue)
            switch issue {
            case .ekycRejected:
                OstelcoAnalytics.logEvent(.identificationFailed(
                    regionCode: region.region.id,
                    countryCode: LocationController.shared.currentCountry?.countryCode ?? "",
                    ekycMethod: localContext.selectedVerificationOption?.rawValue ?? "",
                    failureReason: issue.displayTitle)
                )
            default:
                break
            }
            ohNo.primaryButtonAction = { [weak self] in
                switch issue {
                case .ekycRejected:
                    self?.localContext.selectedVerificationOption = nil
                    self?.localContext.hasSeenJumioInstructions = false
                    self?.localContext.hasCompletedJumio = false
                    self?.advance()
                default:
                    self?.advance()
                }
            }
            navigationController.present(ohNo, animated: true, completion: nil)
        case .locationProblem(let problem):
            let locationProblem = LocationProblemViewController.fromStoryboard()
            locationProblem.delegate = self
            locationProblem.locationProblem = problem
            navigationController.setViewControllers([locationProblem], animated: true)
        case .awesome:
            let awesome = SignUpCompletedViewController.fromStoryboard()
            awesome.delegate = self
            navigationController.setViewControllers([awesome], animated: true)
        case .done:
            delegate?.onboardingCompleteForRegion(region.region.id)
        }
    }
  
    /**
     Returns a simProfile from server and caches it in memory for future calls.
     */
    func makeSimProfileForRegion(_ regionCode: String) -> PromiseKit.Promise<SimProfile> {
        if let simProfile = localContext.simProfile, simProfile.status == .AVAILABLE_FOR_DOWNLOAD {
            return PromiseKit.Promise.value(simProfile)
        }
        
        localContext.simProfile = nil
        return self.primeAPI.createSimProfileForRegion(code: regionCode).map { simProfile in
            self.localContext.simProfile = simProfile
            return simProfile
        }
    }
    
    private func checkCameraAccess(completionHandler: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { hasCameraAccess in
            self.localContext.hasCameraProblem = !hasCameraAccess
            completionHandler()
        }
    }
}

extension RegionOnboardingCoordinator: CautionDelegate {
    func userChoseContinue() {
        localContext.hasSeenCaution = true
        advance()
    }
    
    func userChoseCancel() {
        delegate?.onboardingCancelled()
    }
}

extension RegionOnboardingCoordinator: LocationProblemDelegate {
    func retry() {
        advance()
    }
}

extension RegionOnboardingCoordinator: JumioInstructionsDelegate {
    func jumioInstructionsViewed() {
        localContext.hasSeenJumioInstructions = true
        advance()
    }
}
