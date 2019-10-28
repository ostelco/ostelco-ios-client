//
//  RootCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import PromiseKit
import UIKit
import FirebaseAuth
import UserNotifications
import CoreLocation
import AVFoundation
import CoreTelephony

protocol OnboardingCoordinatorDelegate: class {
    func onboardingComplete(force: Bool)
}

class OnboardingCoordinator {
    weak var delegate: OnboardingCoordinatorDelegate?
    
    var localContext = OnboardingContext()
    let stageDecider = StageDecider()
    let primeAPI: PrimeAPI
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, primeAPI: PrimeAPI = APIManager.shared.primeAPI) {
        self.navigationController = navigationController
        self.primeAPI = primeAPI
        
        Auth.auth().addStateDidChangeListener { (_, user) in
            self.localContext.hasFirebaseToken = user != nil
            self.advance()
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let status = settings.authorizationStatus
            self.localContext.hasSeenNotificationPermissions = status != .notDetermined
        }
        
        LocationController.shared.startUpdatingLocation()
    }
    
    func advance() {
        primeAPI.loadContext()
            .done { (context) in
                self.localContext.serverIsUnreachable = false
                
                let location = LocationController.shared
                self.localContext.hasSeenLocationPermissions = location.authorizationStatus != .notDetermined
                self.localContext.locationProblem = location.locationProblem
                
                UserManager.shared.customer = context.customer
                let stage = self.stageDecider.compute(context: context.toLegacyModel(), localContext: self.localContext)
                if stage == .home {
                    self.delegate?.onboardingComplete(force: false)
                } else {
                    self.afterDismissing {
                        self.navigateTo(stage)
                    }
                }
        }.recover { error in
            self.localContext.serverIsUnreachable = (error as NSError).code == -1004
            let context: Context? = nil
            let stage = self.stageDecider.compute(context: context, localContext: self.localContext)
            self.afterDismissing {
                self.navigateTo(stage)
            }
        }
    }
    
    private func afterDismissing(completion: @escaping () -> Void) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    private func navigateTo(_ stage: StageDecider.Stage) {
        switch stage {
        case .loginCarousel:
            let loginViewController = LoginViewController.fromStoryboard()
            loginViewController.delegate = self
            navigationController.setViewControllers([loginViewController], animated: true)
        case .legalStuff:
            let legalStuff = TheLegalStuffViewController.fromStoryboard()
            legalStuff.delegate = self
            navigationController.setViewControllers([legalStuff], animated: true)
        case .nicknameEntry:
            let nicknameEntry = GetStartedViewController.fromStoryboard()
            nicknameEntry.delegate = self
            navigationController.setViewControllers([nicknameEntry], animated: true)
        case .home:
            delegate?.onboardingComplete(force: false)
        case .ohNo(let issue):
            let ohNo = OhNoViewController.fromStoryboard(type: issue)
            ohNo.primaryButtonAction = { [weak self] in
                self?.advance()
            }
            navigationController.present(ohNo, animated: true, completion: nil)
        case .locationPermissions:
            let locationPermissions = AllowLocationAccessViewController.fromStoryboard()
            locationPermissions.delegate = self
            navigationController.setViewControllers([locationPermissions], animated: true)
        case .locationProblem(let problem):
            let locationProblem = LocationProblemViewController.fromStoryboard()
            locationProblem.delegate = self
            locationProblem.locationProblem = problem
            navigationController.present(locationProblem, animated: true, completion: nil)
        case .notificationPermissions:
            let notificationPermissions = EnableNotificationsViewController.fromStoryboard()
            notificationPermissions.delegate = self
            navigationController.setViewControllers([notificationPermissions], animated: true)
        case .awesome:
            let awesome = SignUpCompletedViewController.fromStoryboard()
            awesome.delegate = self
            navigationController.setViewControllers([awesome], animated: true)
        }
    }
}

extension OnboardingCoordinator: LoginDelegate {
    enum FirebaseError: Swift.Error, LocalizedError {
        case noErrorAndNoUser
        
        var localizedDescription: String {
            switch self {
            case .noErrorAndNoUser:
                return NSLocalizedString("Signed into Firebase and received neither a user nor an error!", comment: "Error case during firebase auth when we could not get a user.")
            }
        }
    }
    
    func signedIn(controller: UIViewController, authCode: String, contactEmail: String?) {
        let spinnerView = controller.showSpinner()
        
        UserDefaultsWrapper.contactEmail = contactEmail
        let appleIdToken = AppleIdToken(authCode: authCode)
        primeAPI.authorizeAppleId(with: appleIdToken)
            .then { (customToken) -> PromiseKit.Promise<Void> in
                debugPrint("customToken ", customToken.token, contactEmail ?? "")
                return self.signInWithCustomToken(customToken: customToken.token)
        }
            // The callback for Auth.auth().addStateDidChangeListener() will call advance().
            .catch { error in
                debugPrint("Authorize Error :", error)
                ApplicationErrors.log(error)
                controller.removeSpinner(spinnerView)
                controller.showAlert(
                    title: NSLocalizedString("Sign In Error", comment: "Title for alert when authorize Apple Id fails."),
                    msg: NSLocalizedString("Failed to authorize user, please try again or contact customer support.", comment: "Message for alert when authorize Apple Id fails.")
                )
        }
    }
    
    func signInError(controller: UIViewController, error: Error) {
        debugPrint("Sign In Error :", error)
        ApplicationErrors.log(error)
        controller.showAlert(
            title: NSLocalizedString("Apple Sign In Error", comment: "Title for alert when Sign In with Apple fails."),
            msg: NSLocalizedString("Sign In with Apple Failed, please try again or contact customer support.", comment: "Message for alert when Sign In with Apple fails.")
        )
    }
    
    func signInWithCustomToken(customToken: String) -> Promise<Void> {
        return Promise { seal in
            Auth.auth().signIn(withCustomToken: customToken) { authDataResult, error in
                if let firebaseError = error {
                    seal.reject(firebaseError)
                    return
                }
                guard authDataResult?.user != nil else {
                    seal.reject(FirebaseError.noErrorAndNoUser)
                    return
                }
                
                seal.fulfill(())
            }
        }
    }
}

extension OnboardingCoordinator: TheLegalStuffDelegate {
    func legaleseAgreed() {
        localContext.hasAgreedToTerms = true
        advance()
    }
}

extension OnboardingCoordinator: GetStartedDelegate {
    func enteredNickname(controller: UIViewController, nickname: String) {
        let spinnerView = controller.showSpinner()
        guard let email = UserManager.shared.currentUserEmail else {
            controller.removeSpinner(spinnerView)
            controller.showAlert(
                title: NSLocalizedString("Error", comment: "Error message title"),
                msg: NSLocalizedString("Email is empty or missing in Firebase", comment: "Error message when we don't get info from Firebase")
            )
            return
        }
        
        let user = UserSetup(nickname: nickname, email: email)
        
        primeAPI.createCustomer(with: user)
            .done { [weak self] customer in
                UserManager.shared.customer = PrimeGQL.ContextQuery.Data.Context.Customer(legacyModel: customer)
                OstelcoAnalytics.logEvent(.signup)
                self?.advance()
        }
        .catch { error in
            debugPrint("createCustomer Error :", error)
            ApplicationErrors.log(error)
            controller.removeSpinner(spinnerView)
            controller.showGenericError(error: error)
        }
    }
}

extension OnboardingCoordinator: EnableNotificationsDelegate {
    func requestPermission() {
        PushNotificationController.shared.checkSettingsThenRegisterForNotifications(authorizeIfNotDetermined: true)
            .ensure { [weak self] in
                self?.localContext.hasSeenNotificationPermissions = true
        }
        .done { [weak self] _ in
            self?.advance()
        }
        .catch { [weak self] error in
            switch error {
            case PushNotificationController.Error.notAuthorized:
                // The user declined push notifications. Oh well. Let's move on.
                self?.advance()
            default:
                ApplicationErrors.log(error)
                self?.navigationController.showGenericError(error: error)
            }
        }
    }
    
    func pushAgreedOrDenied() {
        
        advance()
    }
}

extension OnboardingCoordinator: AllowLocationAccessDelegate {
    func handleLocationProblem(_ problem: LocationProblem) {
        localContext.locationProblem = problem
        advance()
    }
    
    func locationUsageAuthorized() {
        localContext.hasSeenLocationPermissions = true
        advance()
    }
    
}

extension OnboardingCoordinator: LocationProblemDelegate {
    func retry() {
        // We'll be informed about other location problems being fixed,
        // but for this one, we just need to let the user pick their country
        // again.
        if case .authorizedButWrongCountry = localContext.locationProblem {
            localContext.locationProblem = nil
        }
        advance()
    }
}

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
            .then { simProfile -> PromiseKit.Promise<Void> in
                switch simProfile.status {
                case .INSTALLED:
                    return PromiseKit.Promise.value(())
                case .AVAILABLE_FOR_DOWNLOAD:
                    if simProfile.isDummyProfile {
                        return PromiseKit.Promise<Void> { seal in
                            controller.showAlert(title: "YOU DID NOT GET AN ESIM", msg: "Triggered fake eSIM path, which means you don't install an eSIM on your phone but we let you pass through the onboarding pretending you have one. This message should only be visible to testers.") { _ in
                                seal.fulfill(())
                            }
                        }
                        
                    }
                    guard simProfile.hasValidESimActivationCode() else {
                        fatalError("Invalid ESim activation code, could not find esim server address or activation code from: \(simProfile.eSimActivationCode)")
                    }
                    return ESimManager.shared.addPlan(address: simProfile.eSimServerAddress, matchingID: simProfile.matchingID, iccid: simProfile.iccId)
                default:
                    fatalError("Invalid simProfile status, expected \(SimProfileStatus.AVAILABLE_FOR_DOWNLOAD) on \(SimProfileStatus.INSTALLED) got: \(simProfile.status)")
                }
                return PromiseKit.Promise.value(())
        }
        .ensure {
            controller.removeSpinner(spinner)
        }
        .done { [weak self] _ in
            OstelcoAnalytics.logEvent(.esimSetupCompleted(regionCode: self?.region.region.id ?? "", countryCode: LocationController.shared.currentCountry?.countryCode ?? ""))
            self?.localContext.hasSeenESIMInstructions = true
            self?.advance()
        }
        .catch { error in
            ApplicationErrors.log(error)
            controller.showAlert(title: "Error", msg: error.localizedDescription)
        }
    }
}

extension OnboardingCoordinator: SignUpCompletedDelegate {
    func acknowledgedSuccess() {
        localContext.hasSeenAwesome = true
        advance()
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
        localContext.hasCompletedJumio = true
        advance()
    }
    
    func scanCancelled() {
        delegate?.onboardingCancelled()
    }
    
    func scanFailed(errorMessage: String) {
        localContext.selectedVerificationOption = nil
        advance()
    }
}

extension RegionOnboardingCoordinator: PendingVerificationDelegate {
    func checkStatus() {
        advance()
    }
    
    func viewDidAppear() {
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
    
    public weak var delegate: RegionOnboardingDelegate?
    
    var singpassCoordinator: SingPassCoordinator?
    var jumioCoordinator: JumioCoordinator?
    
    init(region: PrimeGQL.RegionDetailsFragment, localContext: RegionOnboardingContext, navigationController: UINavigationController, primeAPI: PrimeAPI) {
        self.region = region
        self.localContext = localContext
        self.navigationController = navigationController
        self.primeAPI = primeAPI
        
        advance()
    }
    
    func advance() {
        primeAPI.loadContext()
        .done { (context) in
            self.localContext.serverIsUnreachable = false
            
            UserManager.shared.customer = context.customer
            
            let region = context.regions.map {
                $0.fragments.regionDetailsFragment
            }.first(where: {
                $0.region.id == self.region.region.id
            })!
            
            let stage: StageDecider.RegionStage
            if let problem = self.checkLocation(country: Country(region.region.id)) {
                stage = .locationProblem(problem)
            } else {
                stage = self.stageDecider.stageForRegion(region: RegionResponse(gqlData: region), localContext: self.localContext)
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
        switch stage {
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
            if let jumio = try? JumioCoordinator(regionID: region.region.id, primeAPI: primeAPI) {
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
    
    private func hasMultipleIdentityOptions() -> Bool {
        return stageDecider.identityOptionsForRegionID(region.region.id).count > 1
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
