//
//  OnboardingPageViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import AVFoundation
import ostelco_core
import OstelcoStyles
import UIKit

enum OnboardingPage: Int, CaseIterable {
    case whatIsOya
    case noNeedToChange
    case fullyDigital
    
    var gifVideo: GifVideo {
        switch self {
        case .whatIsOya:
            return .arrow_up
        case .noNeedToChange:
            return .heart
        case .fullyDigital:
            return .app
        }
    }
    
    var linkableText: LinkableText? {
        switch self {
        case .whatIsOya:
            return LinkableText(
                fullText: NSLocalizedString("OYA is a simple way to get extra mobile data\n\nNo monthly fees\n\nJust extra data when you need it!", comment: "Login onboarding step 1 text"),
                linkedPortion: nil
            )
        case .noNeedToChange:
            return LinkableText(
                fullText: NSLocalizedString("No need to change telco!\n\nWhen you’re running low on data, get some extra from OYA\n\nOYA data never expires, so it’s there when you need it!", comment: "Login onboarding step 2 text"),
                linkedPortion: nil
            )
        case .fullyDigital:
            return LinkableText(
                fullText: NSLocalizedString("OYA is fully digital\n\nNo need to wait for a SIM card in the mail\n\nTry it now! With 1GB free data", comment: "Login onboarding step 3 text"),
                linkedPortion: Link(
                    NSLocalizedString("fully digital", comment: "Login onboarding step 3 linkable part"),
                    url: ExternalLink.fullyDigital.url
                )
            )
        }
    }
    
    var viewController: OnboardingPageViewController {
        return OnboardingPageViewController.fromStoryboard(with: self)
    }
}

class OnboardingPageViewController: UIViewController {
    
    @IBOutlet private var copyLabel: OnboardingLabel!
    
    @IBOutlet private var gifView: LoopingVideoView!
    
    // This is set up in the convenience constructor
    private(set) var onboardingPage: OnboardingPage!
    
    /// Convenience constructor
    ///
    /// - Parameter page: The page you wish to display.
    static func fromStoryboard(with page: OnboardingPage) -> OnboardingPageViewController {
        let vc = fromStoryboard()
        vc.onboardingPage = page
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.videoURL = onboardingPage.gifVideo.url
        guard let linkableText = onboardingPage.linkableText else {
            ApplicationErrors.assertAndLog("Couldn't instantiate onboarding page linkable text for page \(onboardingPage!)")
            return
        }
        
        copyLabel.tapDelegate = self
        copyLabel.setLinkableText(linkableText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gifView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gifView.pause()
    }
}

extension OnboardingPageViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .login
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}

extension OnboardingPageViewController: LabelTapDelegate {
    
    func tappedLink(_ link: Link) {
        UIApplication.shared.open(link.url)
    }
}
