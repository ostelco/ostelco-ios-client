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
            self.localContext.enteredEmailAddress = UserDefaultsWrapper.pendingEmail
            self.localContext.hasFirebaseToken = user != nil
            self.advance()
        }
    }
    
    func advance() {
        primeAPI.loadContext()
            .done { (context) in
                self.localContext.serverIsUnreachable = false
                
                UserManager.shared.customer = context.customer?.fragments.customerFields
                let stage = self.stageDecider.compute(context: context, localContext: self.localContext)
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
        case .emailEntry:
            let emailEntry = EmailEntryViewController.fromStoryboard()
            emailEntry.delegate = self
            navigationController.setViewControllers([emailEntry], animated: true)
        case .checkYourEmail:
            let checkYourEmail = CheckEmailViewController.fromStoryboard()
            checkYourEmail.delegate = self
            navigationController.setViewControllers([checkYourEmail], animated: true)
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
            singpassCoordinator = SingPassCoordinator(delegate: self)
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
            if let country = localContext.selectedRegion?.country, let jumio = try? JumioCoordinator(country: country) {
                jumio.delegate = self
                jumio.startScan(from: navigationController)
                self.jumioCoordinator = jumio
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
        LocationController.shared.checkInCorrectCountry(country)
            .done {
                self.localContext.regionVerified = true
                self.localContext.locationProblem = nil
                self.advance()
            }.catch { (error) in
                if case LocationController.Error.locationProblem(let problem) = error {
                    self.localContext.locationProblem = problem
                }
                self.advance()
        }
    }
}

extension OnboardingCoordinator: LoginDelegate {
    func loginCarouselSeen() {
        localContext.hasSeenLoginCarousel = true
        advance()
    }
}

extension OnboardingCoordinator: EmailEntryDelegate {
    func sendEmailLink(email: String) {
        
        let spinnerView = navigationController.showSpinner()
        EmailLinkManager.linkEmail(email)
        .ensure { [weak self] in
            self?.navigationController.removeSpinner(spinnerView)
        }
        .done { [weak self] (_) in
            self?.localContext.enteredEmailAddress = email
            UserDefaultsWrapper.pendingEmail = email
            self?.advance()
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
    }
}

extension OnboardingCoordinator: CheckEmailDelegate {
    func resendLoginEmail() {
        guard let email = UserDefaultsWrapper.pendingEmail else {
            ApplicationErrors.assertAndLog("No pending email?!")
            return
        }
        
        let spinnerView = navigationController.showSpinner()
        EmailLinkManager.linkEmail(email)
        .ensure { [weak self] in
            self?.navigationController.removeSpinner(spinnerView)
        }
        .done { [weak self] in
            let messageFormat = NSLocalizedString("We've resent your email to %@. If you're still having issues, please contact support.", comment: "Message for alert when login email is re-sent.")
            self?.navigationController.showAlert(
                title: NSLocalizedString("Resent!", comment: "Title for alert when login email is re-sent."),
                msg: String(format: messageFormat, email)
            )
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
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
    func enteredNickname(_ nickname: String) {
        guard let email = UserManager.shared.currentUserEmail else {
            navigationController.showAlert(
                title: NSLocalizedString("Error", comment: "Error message title"),
                msg: NSLocalizedString("Email is empty or missing in Firebase", comment: "Error message when we don't get info from Firebase")
            )
            return
        }
        
        let user = UserSetup(nickname: nickname, email: email)
        
        primeAPI.createCustomer(with: user)
        .done { [weak self] customer in
            OstelcoAnalytics.logEvent(.EnteredNickname)
            UserManager.shared.customer = customer 
            self?.advance()
        }
        .cauterize()
        // There is no catch. The only reason this could error is if the server is unreachable which we handle otherwise.
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
    func selectedCountry() -> Country {
        guard let country = localContext.selectedRegion?.country else {
            fatalError("There is no selected region in the local context!")
        }
        return country
    }
    
    func handleLocationProblem(_ problem: LocationProblem) {
        localContext.locationProblem = problem
        advance()
    }
    
    func locationUsageAuthorized() {
        checkLocation()
    }
    
}

extension OnboardingCoordinator: LocationProblemDelegate {
    func retry() {
        localContext.selectedRegion = nil
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
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate) {
        let addressController = AddressEditViewController.fromStoryboard()
        addressController.mode = .myInfoVerify(myInfo: address)
        addressController.myInfoDelegate = delegate
        addressController.delegate = self
        navigationController.pushViewController(addressController, animated: true)
    }
    
    func verifiedSingPassAddress() {
        advance()
    }

    func failedToLoadMyInfo() {
        localContext.selectedVerificationOption = nil
        localContext.myInfoCode = nil
        advance()
    }
}

extension OnboardingCoordinator: AddressEditDelegate {
    func entered(address: EKYCAddress) {
        primeAPI
        .addAddress(address, forRegion: countryCode())
        .done { [weak self] _ in
            self?.localContext.hasCompletedAddress = true
            self?.advance()
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
    }
    
    func countryCode() -> String {
        return selectedCountry().countryCode
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
    func completedInstructions() {
        localContext.hasSeenESIMInstructions = true
        
        primeAPI.loadContext()
        .then { (context) -> PromiseKit.Promise<PrimeGQL.SimProfileFields> in
            let countryCode = context.toLegacyModel().getRegion()!.region.id
            return APIManager.shared.primeAPI.createSimProfileForRegion(code: countryCode)
        }
        .done { [weak self] (_) -> Void in
            self?.advance()
        }
        .catch { [weak self] error in
            ApplicationErrors.log(error)
            self?.navigationController.showGenericError(error: error)
        }
    }
}

extension OnboardingCoordinator: ESIMPendingDownloadDelegate {
    func resendEmail() {
        primeAPI.loadContext()
        .then { (context) -> PromiseKit.Promise<PrimeGQL.SimProfileFields> in
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
        APIManager.shared.primeAPI
        .validateNRIC(nric, forRegion: countryCode())
        .ensure {
            controller.removeSpinner(spinnerView)
        }
        .done { [weak self] _ in
            self?.advance()
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
