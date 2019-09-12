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

protocol OnboardingCoordinatorDelegate: class {
    func onboardingComplete()
}

class OnboardingCoordinator {
    weak var delegate: OnboardingCoordinatorDelegate?
    
    var localContext = LocalContext()
    let stageDecider = StageDecider()
    let primeAPI: PrimeAPI
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, primeAPI: PrimeAPI = APIManager.shared.primeAPI) {
        self.navigationController = navigationController
        self.primeAPI = primeAPI
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let status = settings.authorizationStatus
            self.localContext.hasSeenNotificationPermissions = status != .notDetermined
        }
        
        Auth.auth().addStateDidChangeListener { (_, user) in
            self.localContext.hasFirebaseToken = user != nil
            self.advance()
        }
        
        LocationController.shared.startUpdatingLocation()
    }
    
    func advance() {
        primeAPI.loadContext()
            .done { (context) in
                self.localContext.serverIsUnreachable = false
                if let region = context.toLegacyModel().getRegion()?.region {
                    self.localContext.selectedRegion = Region(gqlRegion: region)
                }
                
                UserManager.shared.customer = context.customer
                let stage = self.stageDecider.compute(context: context.toLegacyModel(), localContext: self.localContext)
                self.afterDismissing {
                    self.navigateTo(stage)
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
        case .notificationPermissions:
            let notificationPermissions = EnableNotificationsViewController.fromStoryboard()
            notificationPermissions.delegate = self
            navigationController.setViewControllers([notificationPermissions], animated: true)
        case .regionOnboarding:
            let regionOnboarding = VerifyCountryOnBoardingViewController.fromStoryboard()
            regionOnboarding.delegate = self
            navigationController.setViewControllers([regionOnboarding], animated: true)
        case .selectRegion:
            let chooseCountry = ChooseCountryViewController.fromStoryboard()
            chooseCountry.delegate = self
            DispatchQueue.main.async {
                if let country = LocationController.shared.currentCountry {
                    chooseCountry.selected(country: country)
                }
            }
            
            navigationController.setViewControllers([chooseCountry], animated: true)
        case .locationPermissions:
            let locationPermissions = AllowLocationAccessViewController.fromStoryboard()
            locationPermissions.delegate = self
            navigationController.setViewControllers([locationPermissions], animated: true)
        case .locationProblem(let problem):
            let locationProblem = LocationProblemViewController.fromStoryboard()
            locationProblem.delegate = self
            locationProblem.locationProblem = problem
            navigationController.present(locationProblem, animated: true, completion: nil)
        case .verifyIdentityOnboarding:
            let verifyIdentify = VerifyIdentityOnBoardingViewController.fromStoryboard()
            verifyIdentify.delegate = self
            navigationController.setViewControllers([verifyIdentify], animated: true)
        case .selectIdentityVerificationMethod:
            let selectEKYCMethod = SelectIdentityVerificationMethodViewController.fromStoryboard()
            selectEKYCMethod.delegate = self
            navigationController.setViewControllers([selectEKYCMethod], animated: true)
        case .singpass:
            singpassCoordinator = SingPassCoordinator(delegate: self, primeAPI: primeAPI)
            singpassCoordinator?.startLogin(from: navigationController)
        case .verifyMyInfo(let code):
            let verifyMyInfo = MyInfoSummaryViewController.fromStoryboard()
            verifyMyInfo.myInfoCode = code
            verifyMyInfo.delegate = self
            navigationController.setViewControllers([verifyMyInfo], animated: true)
        case .eSimOnboarding:
            let eSimOnboarding = ESIMOnBoardingViewController.fromStoryboard()
            eSimOnboarding.delegate = self
            navigationController.setViewControllers([eSimOnboarding], animated: true)
        case .eSimInstructions:
            let instructions = ESIMInstructionsViewController.fromStoryboard()
            instructions.delegate = self
            navigationController.setViewControllers([instructions], animated: true)
        case .pendingESIMInstall:
            let pending = ESIMPendingDownloadViewController.fromStoryboard()
            pending.delegate = self
            navigationController.setViewControllers([pending], animated: true)
        case .awesome:
            let awesome = SignUpCompletedViewController.fromStoryboard()
            awesome.delegate = self
            navigationController.setViewControllers([awesome], animated: true)
        case .home:
            delegate?.onboardingComplete()
        case .nric:
            let nric = NRICVerifyViewController.fromStoryboard()
            nric.delegate = self
            navigationController.setViewControllers([nric], animated: true)
        case .jumio:
            if let country = localContext.selectedRegion?.country, let jumio = try? JumioCoordinator(country: country, primeAPI: primeAPI) {
                self.jumioCoordinator = jumio
                
                jumio.delegate = self
                jumio.startScan(from: navigationController)
            }
        case .address:
            let addressController = AddressEditViewController.fromStoryboard()
            addressController.mode = .nricEnter
            addressController.delegate = self
            navigationController.setViewControllers([addressController], animated: true)
        case .pendingVerification:
            let pending = PendingVerificationViewController.fromStoryboard()
            pending.delegate = self
            navigationController.setViewControllers([pending], animated: true)
        case .ohNo(let issue):
            if case .ekycRejected = issue {
                localContext.hasCompletedJumio = false
            }
            
            let ohNo = OhNoViewController.fromStoryboard(type: issue)
            ohNo.primaryButtonAction = { [weak self] in
                self?.advance()
            }
            navigationController.present(ohNo, animated: true, completion: nil)
        }
    }
    
    var singpassCoordinator: SingPassCoordinator?
    var jumioCoordinator: JumioCoordinator?
    
    private func checkLocation() {
        guard let country = localContext.selectedRegion?.country else {
            fatalError("Shouldn't be possible to be here without a country!")
        }
        
        let controller = LocationController.shared
        if controller.checkInCorrectCountry(country) {
            localContext.regionVerified = true
            localContext.locationProblem = nil
        } else {
            localContext.locationProblem = controller.locationProblem
        }
        advance()
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
            debugPrint("customToken ", customToken.token)
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
            OstelcoAnalytics.logEvent(.EnteredNickname)
            UserManager.shared.customer = PrimeGQL.ContextQuery.Data.Context.Customer(legacyModel: customer)
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

extension OnboardingCoordinator: VerifyCountryOnBoardingDelegate {
    func finishedViewingCountryLandingScreen() {
        localContext.hasSeenRegionOnboarding = true
        advance()
    }
}

extension OnboardingCoordinator: ChooseCountryDelegate {
    func selectedCountry(_ country: Country) {
        localContext.selectedRegion = Region(id: country.countryCode, name: country.name!)
        
        let locationStatus = CLLocationManager.authorizationStatus()
        if locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse {
            checkLocation()
        } else {
            advance()
        }
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
        localContext.selectedRegion = nil
        // We'll be informed about other location problems being fixed,
        // but for this one, we just need to let the user pick their country
        // again.
        if case .authorizedButWrongCountry = localContext.locationProblem {
            localContext.locationProblem = nil
        }
        advance()
    }
}

extension OnboardingCoordinator: VerifyIdentityOnboardingDelegate {
    func showFirstStepAfterLanding() {
        localContext.hasSeenVerifyIdentifyOnboarding = true
        advance()
    }
}

extension OnboardingCoordinator: SelectIdentityVerificationMethodDelegate {
    func selected(option: IdentityVerificationOption) {
        localContext.selectedVerificationOption = option
        advance()
    }
}

extension OnboardingCoordinator: SingPassCoordinatorDelegate {
    func signInSucceeded(myInfoQueryItems: [URLQueryItem]) {
        let code = myInfoQueryItems.first(where: { $0.name == "code" })?.value
        localContext.myInfoCode = code
        advance()
    }
    
    func signInFailed(error: NSError?) {
        print(error ?? "no error")
    }
}

extension OnboardingCoordinator: MyInfoSummaryDelegate {
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
        let regionCode = localContext.selectedRegion?.id
        
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

extension OnboardingCoordinator: AddressEditDelegate {
    func entered(address: EKYCAddress) {
        primeAPI
        .addAddress(address, forRegion: countryCode())
        .done { [weak self] in
            self?.localContext.hasCompletedAddress = true
            self?.advance()
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
    }
    
    func countryCode() -> String {
        return localContext.selectedRegion!.country.countryCode
    }
    
    func cancel() {
        navigationController.popViewController(animated: true)
    }
}

extension OnboardingCoordinator: ESIMOnBoardingDelegate {
    func completedLanding() {
        localContext.hasSeenESimOnboarding = true
        advance()
    }
}

extension OnboardingCoordinator: ESIMInstructionsDelegate {
    func completedInstructions(_ controller: ESIMInstructionsViewController) {
        localContext.hasSeenESIMInstructions = true
        
        let spinner = controller.showSpinner()
        
        primeAPI.loadContext()
        .then { (context) -> PromiseKit.Promise<PrimeGQL.SimProfileFields> in
            assert(context.regions.count == 1)
            // swiftlint:disable:next empty_count
            assert(context.regions.first!.fragments.regionDetailsFragment.simProfiles?.count == 0)
            
            let simProfile = RegionResponse.getRegionFromRegionResponseArray(context.regions.map({ $0.fragments.regionDetailsFragment }))?.getSimProfile()
            if let simProfile = simProfile {
                return PromiseKit.Promise.value(simProfile)
            } else {
                let countryCode = context.toLegacyModel().getRegion()!.region.id
                return self.primeAPI.createSimProfileForRegion(code: countryCode).map { $0.getGraphQLModel().fragments.simProfileFields }
            }
        }
        .ensure {
            controller.removeSpinner(spinner)
        }
        .done { [weak self] (_) -> Void in
            self?.advance()
        }
        .catch { error in
            ApplicationErrors.log(error)
            controller.showGenericError(error: error)
        }
    }
}

extension OnboardingCoordinator: ESIMPendingDownloadDelegate {
    func resendEmail(controller: UIViewController) {
        let spinnerView = controller.showSpinner()
        primeAPI.loadContext()
        .then { (context) -> PromiseKit.Promise<SimProfile> in
            let region = context.toLegacyModel().getRegion()!
            let profile = region.getSimProfile()!
            return self.primeAPI.resendEmailForSimProfileInRegion(code: region.region.id, iccId: profile.iccId)
        }
        .done { [weak self] _ in
            self?.navigationController.showAlert(
                title: NSLocalizedString("Message", comment: "Title for alert when we resend esim email."),
                msg: NSLocalizedString("We have resent the QR code to your email address.", comment: "Message for alert when we resend esim email.")
            )
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
        .finally {
            controller.removeSpinner(spinnerView)
        }
    }
    
    func checkAgain() {
        advance()
    }
}

extension OnboardingCoordinator: SignUpCompletedDelegate {
    func acknowledgedSuccess() {
        localContext.hasSeenAwesome = true
        advance()
    }
}

extension OnboardingCoordinator: NRICVerifyDelegate {
    func enteredNRICS(_ controller: NRICVerifyViewController, nric: String) {
        let spinnerView = controller.showSpinner()
        primeAPI
        .validateNRIC(nric, forRegion: countryCode())
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

extension OnboardingCoordinator: JumioCoordinatorDelegate {
    func scanSucceeded(scanID: String) {
        localContext.hasCompletedJumio = true
        advance()
    }
    
    func scanCancelled() {
        localContext.hasSeenVerifyIdentifyOnboarding = false
        localContext.selectedVerificationOption = nil
        advance()
    }
    
    func scanFailed(errorMessage: String) {
        localContext.selectedVerificationOption = nil
        advance()
    }
}

extension OnboardingCoordinator: PendingVerificationDelegate {
    func checkStatus() {
        advance()
    }
}
