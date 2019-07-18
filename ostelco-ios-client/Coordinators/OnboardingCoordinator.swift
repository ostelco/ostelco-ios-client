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
                self.localContext.serverIsUnreachable = true
                
                UserManager.shared.customer = context.customer
                let stage = self.stageDecider.compute(context: context, localContext: self.localContext)
                self.afterDismissing {
                    self.navigateTo(stage)
                }
            }.recover { error in
                self.localContext.serverIsUnreachable = (error as NSError).code == -1004
                
                let stage = self.stageDecider.compute(context: nil, localContext: self.localContext)
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
    func emailLinkSent(email: String) {
        localContext.enteredEmailAddress = email
        UserDefaultsWrapper.pendingEmail = email
        advance()
    }
}

extension OnboardingCoordinator: TheLegalStuffDelegate {
    func legaleseAgreed() {
        localContext.hasAgreedToTerms = true
        advance()
    }
}

extension OnboardingCoordinator: GetStartedDelegate {
    func nameEnteredSuccessfully() {
        advance()
    }
}

extension OnboardingCoordinator: EnableNotificationsDelegate {
    func pushAgreedOrDenied() {
        localContext.hasSeenNotificationPermissions = true
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
    
    func locationUsageAuthorized(for country: Country) {
        if country == localContext.selectedRegion?.country {
            localContext.regionVerified = true
            advance()
        }
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
}

extension OnboardingCoordinator: AddressEditDelegate {
    func enteredAddressSuccessfully() {
        localContext.hasCompletedAddress = true
        advance()
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
        advance()
    }
}

extension OnboardingCoordinator: ESIMPendingDownloadDelegate {
    func profileChanged(_ profile: SimProfile) {
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
    func waitingCompletedSuccessfully(for region: RegionResponse) {
        advance()
    }
    
    func waitingCompletedWithRejection() {
        advance()
    }
}
