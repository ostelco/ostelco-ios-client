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
            return LinkableText(fullText: """
            OYA is a simple way to get extra mobile data
            
            No monthly fees
            
            Just extra data when you need it!
            """, linkedPortion: nil)
        case .noNeedToChange:
            return LinkableText(fullText: """
            No need to change telco!
            
            When you’re running low on data, get some extra from OYA
            
            OYA data never expires, so it’s there when you need it!
            """, linkedPortion: nil)
        case .fullyDigital:
            return LinkableText(fullText: """
            OYA is fully digital
            
            No need to wait for a SIM card in the mail
            
            Try it now! With 1GB free data
            """, linkedPortion: "fully digital")
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
    // swiftlint:disable:next implicitly_unwrapped_optional
    private(set) var onboardingPage: OnboardingPage!
    
    /// Convenience constructor
    ///
    /// - Parameter page: The page you wish to display.
    static func fromStoryboard(with page: OnboardingPage) -> OnboardingPageViewController {
        let vc = self.fromStoryboard()
        vc.onboardingPage = page
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gifView.videoURL = self.onboardingPage.gifVideo.url
        guard let linkableText = self.onboardingPage.linkableText else {
            ApplicationErrors.assertAndLog("Couldn't instantiate onboarding page linkable text for page \(self.onboardingPage!)")
            return
        }
        
        self.copyLabel.tapDelegate = self
        self.copyLabel.setLinkableText(linkableText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gifView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.gifView.pause()
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
    
    func tappedAttributedLabel(_ label: UILabel, at index: Int) {
        guard self.onboardingPage.linkableText!.isIndexLinked(index) else {
            // Did not actually tap a link
            return
        }
        
        switch self.onboardingPage! {
        case .fullyDigital:
            UIApplication.shared.open(ExternalLink.fullyDigital.url)
        default:
            break
        }
    }
}
