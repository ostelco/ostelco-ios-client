//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit
import Firebase
import RxSwift

class LoginViewController: UIViewController {
    var spinnerView: UIView?
    
    let disposeBag = DisposeBag()
    
    @IBOutlet private var primaryButton: UIButton!
    
    /// Has to be set up through `prepareForSegue` when this VC is loaded
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var pageController: UIPageViewController!
    
    private lazy var dataSource: PageControllerDataSource = {
        let pages = OnboardingPage.allCases.map { $0.viewController }
        return PageControllerDataSource(pageController: self.pageController,
                                        viewControllers: pages,
                                        pageIndicatorTintColor: OstelcoColor.paleGrey.toUIColor,
                                        currentPageIndicatorTintColor: OstelcoColor.oyaBlue.toUIColor,
                                        delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = self.dataSource.currentIndex
        self.configureButtonTitle(for: index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? UIPageViewController {
            self.pageController = pageController
        }
    }
    
    private func configureButtonTitle(for index: Int) {
        if index == (OnboardingPage.allCases.count - 1) {
            // This is the last page.
            self.primaryButton.setTitle("Sign In", for: .normal)
        } else {
            self.primaryButton.setTitle("Next", for: .normal)
        }
    }
    
    @IBAction private func primaryButtonTapped(_ sender: UIButton) {
        Analytics.logEvent("button_tapped", parameters: [
            "newValue": sender.title(for: .normal)!
            ])
        
        let index = self.dataSource.currentIndex
        if index == (OnboardingPage.allCases.count - 1) {
            self.signInTapped()
        } else {
            self.dataSource.goToNextPage()
        }
    }
    
    private func signInTapped() {
        UserManager.sharedInstance.showLogin(from: self)
        
//        sharedAuth.loginWithAuth0().subscribe(
//            onNext: { _ in
//                // TODO: Duplicated logic from SplashViewController
//                DispatchQueue.main.async {
//                    self.loadCustomer()
//                }
//        },
//            onError: { error in
//                DispatchQueue.main.async {
//                    self.handleLoginFailure(message: "\(error)")
//                }
//        })
//            .disposed(by: self.disposeBag)
    }
    
    private func loadCustomer() {
        self.spinnerView = self.showSpinner(onView: self.view)
        
        APIManager.sharedInstance.loggedInAPI.loadContext()
            .ensure { [weak self] in
                self?.removeSpinner(self?.spinnerView)
                self?.spinnerView = nil
            }
            .done { [weak self] context in
                UserManager.sharedInstance.user = context.customer
                guard let region = context.getRegion() else {
                    self?.showCountry()
                    return
                }
                self?.handleRegionResponse(region)
                
            }
            .catch { [weak self] error in
                switch error {
                case APIHelper.Error.invalidResponseCode(let code, _):
                    if code == 404 {
                        self?.showSignUp()
                        return
                    } // else, keep going.
                default:
                    break
                }
                
                ApplicationErrors.log(error)
                self?.showGenericError(error: error)
            }
    }

    private func handleRegionResponse(_ region: RegionResponse) {
        OnBoardingManager.sharedInstance.region = region
        switch region.status {
        case .PENDING:
            if let jumio = region.kycStatusMap.JUMIO,
                let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER,
                let nricFin = region.kycStatusMap.NRIC_FIN {
                switch (jumio, addressAndPhoneNumber, nricFin) {
                case (.APPROVED, .APPROVED, .APPROVED):
                    self.showEKYCLastScreen()
                case (.REJECTED, _, _):
                    self.showEKYCOhNo()
                case (.PENDING, .APPROVED, .APPROVED):
                    self.showESim()
                default:
                    self.showCountry()
                }
            } else {
                self.showCountry()
                self.perform(#selector(self.showCountry), with: nil, afterDelay: 0.5)
            }
        case .APPROVED:
            // TODO: Redirect based on sim profiles in region
            guard let simProfile = region.getSimProfile() else {
                self.showESim()
                return
            }
            
            switch simProfile.status {
            // TODO: NOT_READY should probably send user to one of our error screens
            case .AVAILABLE_FOR_DOWNLOAD,
                 .NOT_READY:
                self.showESim()
            default:
                self.showHome()
            }
        case .REJECTED:
            self.showEKYCOhNo()
        }
    }
    
    @objc private func showCountry() {
        performSegue(withIdentifier: "showCountry", sender: self)
    }
    
    @objc private func showSignUp() {
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    @objc private func showEKYCLastScreen() {
        performSegue(withIdentifier: "showEKYCLastScreen", sender: nil)
    }
    
    @objc private func showEKYCOhNo() {
        let ohNo = OhNoViewController.fromStoryboard(type: .ekycRejected)
        ohNo.primaryButtonAction = {
            ohNo.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                let selectVerificationMethodVC = SelectIdentityVerificationMethodViewController.fromStoryboard()
                self.present(selectVerificationMethodVC, animated: true)
            })
        }
        self.present(ohNo, animated: true)
    }
    
    @objc private func showESim() {
        performSegue(withIdentifier: "showESim", sender: nil)
    }
    
    @objc private func showHome() {
        performSegue(withIdentifier: "showHome", sender: nil)
    }
    
    private func handleLoginFailure(message: String) {
        let alert = UIAlertController(title: "Failed to login", message: "Please try again later.\nIf this problem persists, contact customer support.\n Error: \(message)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: PageControllerDataSourceDelegate {
 
    func pageChanged(to index: Int) {
        self.configureButtonTitle(for: index)
    }
}

extension LoginViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .login
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
